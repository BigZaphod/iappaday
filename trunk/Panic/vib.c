/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <time.h>

extern void * _CTServerConnectionCreate(CFAllocatorRef, int (*)(void *, CFStringRef, CFDictionaryRef, void *), int *);
extern int _CTServerConnectionSetVibratorState(int *, void *, int, int, int, int, int);

int callback(void *connection, CFStringRef string, CFDictionaryRef dictionary, void *data) {
	return 0;
}

void vibrate( int seconds ){
	int x = 0;
	void *connection = _CTServerConnectionCreate(kCFAllocatorDefault, callback, &x);
	int ret = _CTServerConnectionSetVibratorState(&x, connection, 3, 10, 10, 10, 10);
	time_t then = time(NULL);
	while( time(NULL) - then < seconds );
	_CTServerConnectionSetVibratorState(&x, connection, 0, 10, 10, 10, 10);
}

