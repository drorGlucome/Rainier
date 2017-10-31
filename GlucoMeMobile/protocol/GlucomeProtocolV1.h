//
//  ProtocolDecoder.h
//  audioGraph
//
//  Created by Yiftah Ben Aharon on 8/28/12.
//
//

#import <Foundation/Foundation.h>
#import "AudioUnit/AudioComponent.h"
#import "AudioUnit/AudioUnit.h"
#import <AudioToolbox/AudioServices.h>
#import <Accelerate/Accelerate.h>
#import "GlucomeProtocol.h"

#define TONE_A  3300
#define TONE_B  3400
#define TONE_DATA_MIN  3000.0
#define TONE_DATA_MAX  4500.0
#define NUMBER_DATA_MIN   0.0
#define NUMBER_DATA_MAX  255.0
#define DATA_SIZE 10



@interface GlucomeProtocolV1 : GlucomeProtocol

- (void)start;
- (void)stop;
- (void) decode;
- (void)setDelegate:(id)delegate;
- (void)addSample:(float)sample;



@property (assign, nonatomic) int glucose;
@property (assign, nonatomic) int battery;
@property (assign, nonatomic) int crc;

@end

 
    
    
    // protocol sync
    NSTimer* timer;

    
    








