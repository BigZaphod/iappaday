/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "TonePlayer.h"
#import <Celestial/AVSystemController.h>

extern CFRunLoopRef CFRunLoopGetCurrent(void);
static const int TONESamplesPerBuffer = 44100 / 25;	// enough samples for 1/25th of a second  (the bigger this is, the longer the lag)

@implementation Tone
-(void)_generateToneSamples
{
	const float samplesPerCycle = 44100.0f / frequency;

	currentSample = 0;
	numberOfSamples = (int)samplesPerCycle;
	samples = malloc( sizeof(float) * numberOfSamples );

	int i;
	for( i=0; i<numberOfSamples; i++ )
		samples[i] = sinf(i / samplesPerCycle * 2.0f * M_PI);
}

-(BOOL)isEqual: (Tone*)t
{
	return frequency == t->frequency;
}

-(id)initWithFrequency: (float)f
{
	[super init];
	frequency = f;
	[self _generateToneSamples];
	return self;
}

+(id)toneWithFrequency: (float)f
{
	return [[[Tone alloc] initWithFrequency: f] autorelease];
}

-(float)nextSample
{
	currentSample = (currentSample == numberOfSamples-1)? 0: currentSample+1;
	return samples[currentSample];
}

-(void)dealloc
{
	free( samples );
	[super dealloc];
}

@end

// ------------------

@implementation TonePlayer

-(void)dealloc
{
	AudioQueueDispose( queue, true );	// also destroys the buffers
	[tones release];
	[super dealloc];
}

static void AQBufferCallback( void *in, AudioQueueRef inQ, AudioQueueBufferRef outQB )
{
	TonePlayer *player = (TonePlayer*)in;

	short *buffer = (short*)outQB->mAudioData;
	int currentSample;
	int sampleSlot = 0;

	const short amplitude = (short)(32000.0f * player->volume);
	const NSArray *tones = player->tones;
	const int numberOfTones = [tones count];

	// note, this will "play" silence if no tones are presently registered with the tone player
	// this keeps the playback loop running.. probably not ideal - but easy :)
	for( currentSample=0; currentSample<TONESamplesPerBuffer; currentSample++ ) {

		// loop through set of tones
		//  - fetch each tone's sample
		//  - mix with the other tone samples
		//  - save the resulting sample in the buffer (on each stereo channel)

		float sampleValue = 0;
		if( numberOfTones ) {
			int i;
			for( i=0; i<numberOfTones; i++ ) 
				sampleValue += [[tones objectAtIndex: i] nextSample];
			sampleValue /= numberOfTones;
		}

		sampleValue *= amplitude;
		short s = (short)sampleValue;
		buffer[sampleSlot++] = s;
		buffer[sampleSlot++] = s;
	}

	outQB->mAudioDataByteSize = sizeof(short) * sampleSlot;
	AudioQueueEnqueueBuffer(inQ, outQB, 0, NULL);
}

-(void)syncWithSystemVolume
{
	NSString *audioDeviceName;
	AVSystemController *avs = [AVSystemController sharedAVSystemController];
	[avs getActiveCategoryVolume: &volume andName: &audioDeviceName];
}

-(id)init
{
	UInt32 err;

	audioFormat.mSampleRate = 44100.0;
	audioFormat.mFormatID = kAudioFormatLinearPCM;
	audioFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger; // | kAudioFormatFlagIsPacked;
	audioFormat.mBytesPerPacket = 4;
	audioFormat.mFramesPerPacket = 1;
	audioFormat.mBytesPerFrame = 4;
	audioFormat.mChannelsPerFrame = 2;
	audioFormat.mBitsPerChannel = 16;

	err = AudioQueueNewOutput( &audioFormat, AQBufferCallback, (void*)self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &queue );
	if( err ) printf( "AudioQueueNewOutput error\n" );

	// create buffers for the audio data.
	// using two buffers to avoid audio glitches due to hardware lag (I think that's why, anyway)

	err = AudioQueueAllocateBuffer( queue, audioFormat.mBytesPerFrame * TONESamplesPerBuffer, &buffer1 );
	if( err ) printf( "AudioQueueAllocateBuffer 1 error\n" );

	err = AudioQueueAllocateBuffer( queue, audioFormat.mBytesPerFrame * TONESamplesPerBuffer, &buffer2 );
	if( err ) printf( "AudioQueueAllocateBuffer 2 error\n" );

	tones = [[NSMutableArray alloc] init];

	AVSystemController *avs = [AVSystemController sharedAVSystemController];
	[[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object: avs];
	[self syncWithSystemVolume];

	return self;
}

-(void)volumeChanged:(NSNotification *)notification
{
	[self syncWithSystemVolume];
}


-(void)play
{
	// get things rolling... nothing will play unless buffers of audio data have been added to the queue
	AQBufferCallback( (void*)self, queue, buffer1 );
	AQBufferCallback( (void*)self, queue, buffer2 );

	// now that there is data buffered, let's start playing it!
	UInt32 err = AudioQueueStart( queue, NULL );
	if( err ) printf( "AudioQueueStart error\n" );
}

-(void)stop
{
	AudioQueueStop( queue, true );
}

-(void)addTone: (Tone*)t
{
	if( t ) [tones addObject: t];
}

-(void)removeTone: (Tone*)t
{
	if( t ) [tones removeObject: t];
}

-(void)removeAllTones
{
	[tones removeAllObjects];
}

-(NSArray*)playingTones
{
	return [NSArray arrayWithArray: tones];
}

@end
