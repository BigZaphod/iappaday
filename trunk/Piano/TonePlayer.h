/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <Foundation/Foundation.h>
#import "AudioQueue.h"	// NOTE: this file comes from Leopard's AudioToolbox framework - I cannot distribute it!  Get Leopard :)

@interface Tone : NSObject {
	float frequency;
	float *samples;
	int currentSample;
	int numberOfSamples;
}

-(void)dealloc;
+(id)toneWithFrequency: (float)f;
-(BOOL)isEqual: (Tone*)t;

@end

@interface TonePlayer : NSObject {
	AudioStreamBasicDescription audioFormat;
	AudioQueueRef queue;
	AudioQueueBufferRef buffer1;
	AudioQueueBufferRef buffer2;
	NSMutableArray *tones;
	float volume;
}

-(void)dealloc;
-(id)init;
-(void)play;
-(void)stop;
-(void)addTone: (Tone*)t;
-(void)removeTone: (Tone*)t;
-(void)removeAllTones;
-(NSArray*)playingTones;

@end
