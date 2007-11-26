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
		samples[i] = sinf( i / samplesPerCycle * 2.0f * M_PI );
}

-(BOOL)isEqual: (Tone*)t
{
	return frequency == t->frequency;
}

-(void)startAttack
{
	samplesUntilDecay = attackSamples;
	samplesUntilSustain = decaySamples;
	samplesUntilRelease = -1;
}

-(void)startRelease
{
	if( samplesUntilRelease == -1 )
		samplesUntilRelease = releaseSamples;
}

-(BOOL)releaseDone
{
	return samplesUntilRelease == 0;
}

-(id)initWithFrequency: (float)f attack: (float)a decay: (float)d sustain: (float)s release: (float)r
{
	[super init];
	frequency = f;
	attackSamples = 44100 * a;
	decaySamples = 44100 * d;
	sustainLevel = s;
	releaseSamples = 44100 * r;
	[self _generateToneSamples];
	return self;
}

+(id)toneWithFrequency: (float)f attack: (float)a decay: (float)d sustain: (float)s release: (float)r
{
	return [[[Tone alloc] initWithFrequency: f attack: a decay: d sustain: s release: r] autorelease];
}

-(float)nextSample
{
	currentSample = (currentSample == numberOfSamples-1)? 0: currentSample+1;
	float amplitude;
	if( samplesUntilDecay >= 0 ) {
		amplitude = 1.0 - (samplesUntilDecay / attackSamples);
		samplesUntilDecay--;
	} else if( samplesUntilSustain >= 0 ) {
		amplitude = sustainLevel + ((1.0 - sustainLevel) * (samplesUntilSustain / decaySamples));
		samplesUntilSustain--;
	} else if( samplesUntilRelease > 0 ) {
		amplitude = sustainLevel * (samplesUntilRelease / releaseSamples);
		samplesUntilRelease--;
	} else if( samplesUntilRelease == 0 ) {
		amplitude = 0;
	} else {
		amplitude = sustainLevel;
	}
	return samples[currentSample] * amplitude;
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
	[playingTones release];
	[super dealloc];
}

static void AQBufferCallback( void *in, AudioQueueRef inQ, AudioQueueBufferRef outQB )
{
	TonePlayer *player = (TonePlayer*)in;

	short *buffer = (short*)outQB->mAudioData;
	int currentSample;
	int sampleSlot = 0;
	int i;

	const short amplitude = (short)(32000.0f * player->volume);
	NSArray *playingTones = [NSArray arrayWithArray: player->playingTones];
	const int numberOfTones = [playingTones count];

	// note, this will "play" silence if no tones are presently registered with the tone player
	// this keeps the playback loop running.. probably not ideal - but easy :)
	for( currentSample=0; currentSample<TONESamplesPerBuffer; currentSample++ ) {

		// loop through set of tones
		//  - fetch each tone's sample
		//  - mix with the other tone samples
		//  - save the resulting sample in the buffer (on each stereo channel)

		float sampleValue = 0;
		if( numberOfTones ) {
			for( i=0; i<numberOfTones; i++ ) {
				float s = [[playingTones objectAtIndex: i] nextSample] + 1.0f;
				sampleValue = sampleValue + s - ((sampleValue * s) / 2.0f);
			}
		}

		sampleValue *= amplitude;
		short s = (short)(sampleValue - 1.0f);
		buffer[sampleSlot++] = s;
		buffer[sampleSlot++] = s;
	}

	outQB->mAudioDataByteSize = sizeof(short) * sampleSlot;
	AudioQueueEnqueueBuffer(inQ, outQB, 0, NULL);

	// check for tones that are done with the release phase and then remove them from the player
	for( i=0; i<numberOfTones; i++ ) {
		Tone *t = [playingTones objectAtIndex: i];
		if( [t releaseDone] )
			[player->playingTones removeObject: t];
	}
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
	audioFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
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

	playingTones = [[NSMutableArray alloc] init];

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
	[t startAttack];
	[playingTones addObject: t];
}

-(void)removeTone: (Tone*)t
{
	[t startRelease];
}

-(void)removeAllTones
{
	int i;
	for( i=0; i<[playingTones count]; i++ )
		[self removeTone: [playingTones objectAtIndex: i]];
}

-(NSArray*)playingTones
{
	return [NSArray arrayWithArray: playingTones];
}

-(BOOL)playingTone: (Tone*)t
{
	return [playingTones containsObject: t];
}

@end
