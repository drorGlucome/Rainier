//
//  ViewController.h
//  GlucomeProtocol
//
//  Created by Yiftah Ben Aharon on 3/27/13.
//  Copyright (c) 2013 Yiftah Ben Aharon. All rights reserved.
//


#import "GlucomeProtocol.h"

#define TONE_A  4100
#define TONE_B  4200
#define TONE_MIN  4300
#define TONE_MAX  5800
#define BITS_PER_TONE  4
#define ROUND  100
#define ROUND_FREQ(x) ((int)(x+ROUND/2)/ROUND)*ROUND;
#define TONE_SHIFT  ((int)((TONE_MAX-TONE_MIN)/(pow(2,BITS_PER_TONE)-1)))
#define TONE_Q 4000
#define GLUCOSE_LENGTH  10
#define BATTERY_LENGTH 6
#define CRC_LENGTH 8
#define DATA_LENGTH  ((GLUCOSE_LENGTH+BATTERY_LENGTH+CRC_LENGTH+BITS_PER_TONE-1)/BITS_PER_TONE)



@interface GlucomeProtocolV2 : GlucomeProtocol

- (void)start;
- (void)stop;
- (void) decode;
- (void)setDelegate:(id)delegate;


@property (assign, nonatomic) int glucose;
@property (assign, nonatomic) int battery;
@property (assign, nonatomic) int crc;


@end



NSMutableDictionary* TONES;


