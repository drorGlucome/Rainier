//
//  GlucomeProtocol.m
//  GlucomeProtocol
//
//  Created by Yiftah Ben Aharon on 4/8/13.
//  Copyright (c) 2013 Yiftah Ben Aharon. All rights reserved.
//

#import "GlucomeProtocolV2.h"





@interface GlucomeProtocolV2 ()


@end

@implementation GlucomeProtocolV2
@synthesize glucose;
@synthesize battery;
@synthesize crc;




void* refself;

- (id) init
{
    self = [super init];
    refself = self;
        return self;
}

-(void) start{
    initTones();
    setupFFT();
    initAudioSession();

    initAudioStreams();
    startAudioUnit();
}

- (void)stop{
    if(audioUnit == NULL) {
        return;
    }
    stopProcessingAudio();

    AudioComponentInstanceDispose(*audioUnit);

    for(int i=0;i<SAMPLES_BUFFER_SIZE;i++) {
        if(samples[i] != 0) {
            NSString* msg = [[NSString alloc] initWithFormat:@"%d) %d", i, samples[i]];
         //   NSLog(msg);
        }
    }
    inSync = false;
}








- (void)addSample:(float)frequency {
    int index = (samples_index+SAMPLES_BUFFER_SIZE-1)%SAMPLES_BUFFER_SIZE;
    int freq = ROUND_FREQ(frequency);
//    NSLog(@"FREQ: %d", freq);
    if(samples[index]!= freq && freq >= TONE_Q && freq <= TONE_MAX  && freq % ROUND == 0) {
        samples[samples_index%SAMPLES_BUFFER_SIZE] = freq;
        NSLog(@"added %d to %d", freq, samples_index);
        if(inSync && freq != TONE_Q) {
            dataCount++;
        }
        if(samples[samples_index%SAMPLES_BUFFER_SIZE] == TONE_B &&
           samples[(samples_index-1)%SAMPLES_BUFFER_SIZE] == TONE_A) {
            inSync = true;
            dataCount = 0;
            dataStart = (samples_index+1)%SAMPLES_BUFFER_SIZE;
        }
        samples_index++;
        //NSLog(@"data count %d length %d", dataCount, DATA_LENGTH);
        if(dataCount == DATA_LENGTH) {
            [refself stop];
            [refself decode];
        }
    }
    
}

- (void) decode {
    NSMutableString* res = [[NSMutableString alloc] init];
    int i=0;
    int decoded = 0;
    do {
        int index = (dataStart+i)%SAMPLES_BUFFER_SIZE;
        i++;
        int freq = samples[index];
        if(freq == TONE_Q) {
            continue;
        }
        NSString* bin = [TONES objectForKey:[NSNumber numberWithInteger:freq]];
        if(bin == nil) {
            NSLog(@"nil !!!!: %d", freq);
        }
        else {
            [res appendString:bin];
            decoded++;
        }
        
        
        NSLog(@"Decode %d) %d, %@", i-1, freq, bin);
    } while (decoded < DATA_LENGTH);
    self.glucose = to_dec([res substringWithRange:NSMakeRange(0, GLUCOSE_LENGTH)]);
    self.battery = to_dec([res substringWithRange:NSMakeRange(GLUCOSE_LENGTH, BATTERY_LENGTH)]);
    self.crc = to_dec([res substringWithRange:NSMakeRange(GLUCOSE_LENGTH+BATTERY_LENGTH, CRC_LENGTH)]);
    [delegate performSelectorOnMainThread:@selector(ProtocolDecoderFinished) withObject:self waitUntilDone:NO];

    
}
void initTones() {
    TONES = [[NSMutableDictionary alloc] init];
    int n = pow(2,BITS_PER_TONE);
    for(int i=0;i<n;i++) {
        NSString* value = to_bin(i,BITS_PER_TONE);
        NSInteger  key = ((int)(TONE_MIN + i*TONE_SHIFT + ROUND/2)/ROUND)*ROUND;
        [TONES setObject:value forKey:[NSNumber numberWithInteger:key]];
        NSLog(@"Added %d %d => %@", i, key, value);
    }
}


@end

