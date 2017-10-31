//
//  GlucomeProtocol.m
//  GlucomeProtocol
//
//  Created by Yiftah Ben Aharon on 4/8/13.
//  Copyright (c) 2013 Yiftah Ben Aharon. All rights reserved.
//

#import "GlucomeProtocolV1.h"





@interface GlucomeProtocolV1 ()


@end

@implementation GlucomeProtocolV1





void* refself;

- (id) init
{
    self = [super init];
    refself = self;
    return self;
}

-(void) start{
    setupFFT();
    initAudioSession();
    
    initAudioStreams();
    startAudioUnit();
     [self init];
     timer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                 target:self
                                               selector:@selector(processData)
                                               userInfo:nil
                                                repeats:YES];
}
    





- (void)stop{
    
    if(audioUnit == NULL) {
        return;
    }
    [timer invalidate];
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


- (void) processData {
    NSLog(@"PROCESS DATA WITH %d", samples_index);
    if(samples_index < DATA_SIZE) {
        samples_index = 0;
        return;
    }
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    for(int j=0;j<samples_index;j++) {
        if(samples[j%SAMPLES_BUFFER_SIZE] != 0) {
            NSNumber* tmp = [NSNumber numberWithInt:samples[j%SAMPLES_BUFFER_SIZE]];
            [arr addObject:tmp];
        }
    }
    float val = [self strongValue:arr];
    NSLog(@"val is %f", val);
    self.glucose = (int)(val-TONE_DATA_MIN)/(TONE_DATA_MAX-TONE_DATA_MIN)*(NUMBER_DATA_MAX-NUMBER_DATA_MIN);
    NSLog(@"gl is %d", self.glucose);
    [delegate performSelectorOnMainThread:@selector(ProtocolDecoderFinished) withObject:self waitUntilDone:NO];
    samples_index = 0;
}

- (int) strongValue:(NSMutableArray*)arr {
    NSArray *sortedArray = [arr sortedArrayUsingSelector:@selector(compare:)];
    int ROUND = 10;
    int leadVal = 0;
    int leadCount = 0;
    int curVal = 0;
    int curCount = 0;
    for(int i=0;i<sortedArray.count;i++) {
        int val = [[sortedArray objectAtIndex:i] integerValue];
        int valr =((int)(val+ROUND/2)/ROUND)*ROUND;
        // COUTNIUE CURRENT COUNT
        if(val == curVal) {
            curCount++;
        }
        else {
            // CLOSE PREVIOUS COUNT.
            if(curCount > leadCount) {
                leadCount = curCount;
                leadVal = curVal;
            }
            //START A NEW COUNT
            curVal = valr;
            curCount=1;
        }
    }
    return leadVal;
}







- (void)addSample:(float)frequency {
    
    if(frequency < 0) {
        return;
    }
    if(frequency >= TONE_DATA_MIN && frequency <= TONE_DATA_MAX ) {
        NSLog(@"Add sample: %f to %d", frequency, samples_index);
        samples[samples_index] = frequency;
        samples_index = (samples_index+1)%SAMPLES_BUFFER_SIZE;
    }
}





@end

