//
//  GlucomeProtocol.m
//  GlucomeProtocol
//
//  Created by Yiftah Ben Aharon on 4/8/13.
//  Copyright (c) 2013 Yiftah Ben Aharon. All rights reserved.
//


#import "GlucomeProtocol.h"
#include <sys/time.h>






@interface GlucomeProtocol ()


@end

@implementation GlucomeProtocol
@synthesize uid;
@synthesize error;
@synthesize glucose;
@synthesize battery;
@synthesize crc;
@synthesize demoMode;




id refself;

- (id) init
{
    self = [super init];
    data = NULL;
    [self initParams];
    
    refself = self;
    return self;
        //initCache();
}

void initBuffers() {
    if(data != NULL) {
        return;
    }
    int size = (int)(REC_DURATION/SLOT_DURATION);
    data = malloc(size*sizeof(float*));
    for(int i=0;i<size;i++) {
        float* buff = malloc(MAX_FRAME_LENGTH*sizeof(float));
        memset(buff, 0, MAX_FRAME_LENGTH*sizeof(float));
        data[i] = buff;
    }
    freqs = malloc(MAX_FRAME_LENGTH*sizeof(float));
}

-(void) start{
    initTones();
    setupFFT();
    initAudioSession();
    initBuffers();
    initAudioStreams();
    startAudioUnit();
}

- (void)stop{
    stopProcessingAudio();
    AudioComponentInstanceDispose(*audioUnit);
    inSync = false;
}


- (void)setDelegate:(id)aDelegate {
    delegate = aDelegate; /// Not retained
}

/************ AUDIO CODE **********/


void yba2PitchShift(float pitchShift, long numSampsToProcess, long fftFrameSize,
					long osamp, float sampleRate, float *indata, float *outdata,
					FFTSetup fftSetup, int * frequency1, int * frequency2, int lowpass);

void yba2Spectrogram(float pitchShift, long numSampsToProcess, long fftFrameSize,
                    long osamp, float sampleRate, float *indata, float *outdata,
                    FFTSetup fftSetup, float * buff, float* freqs);


int initAudioSession() {
    
    
    audioUnit = (AudioUnit*)malloc(sizeof(AudioUnit));
    
    if(AudioSessionInitialize(NULL, NULL, NULL, NULL) != noErr) {
        return 1;
    }
    
    if(AudioSessionSetActive(true) != noErr) {
        return 1;
    }
    
    UInt32 sessionCategory =  kAudioSessionCategory_RecordAudio;
    if(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                               sizeof(UInt32), &sessionCategory) != noErr) {
        return 1;
    }
    
    Float32 bufferSizeInSec = SLOT_DURATION; // should be half of tone_length (0.05 for 100ms length)
    if(AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration,
                               sizeof(Float32), &bufferSizeInSec) != noErr) {
        return 1;
    }
    
    // get actuall buffer size
    Float32 audioBufferSize;
    UInt32 size = sizeof (audioBufferSize);
    OSStatus result = AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, &size, &audioBufferSize);
    NSLog(@"Actual buffer size: %lf", audioBufferSize);
    SLOT_DURATION = audioBufferSize;
    
    return 0;
}

int initAudioStreams() {
    UInt32 audioCategory = kAudioSessionCategory_RecordAudio;
    if(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                               sizeof(UInt32), &audioCategory) != noErr) {
        return 1;
    }
    
    
    const UInt32 disableFlag = 0;
   // AudioSessionSetProperty(kAudioOutputUnitProperty_EnableIO, sizeof(disableFlag), &disableFlag);
    
    AudioComponentDescription componentDescription;
    componentDescription.componentType = kAudioUnitType_Output;
    componentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    componentDescription.componentFlags = 0;
    componentDescription.componentFlagsMask = 0;
    AudioComponent component = AudioComponentFindNext(NULL, &componentDescription);
    if(AudioComponentInstanceNew(component, audioUnit) != noErr) {
        return 1;
    }
     
     UInt32 enableOutput        = 0;    // to disable output
     AudioUnitElement outputBus = 0;
     
     AudioUnitSetProperty (
     *audioUnit,
     kAudioOutputUnitProperty_EnableIO,
     kAudioUnitScope_Output,
     outputBus,
     &enableOutput,
     sizeof (enableOutput)
     );
     
     
    UInt32 enableInput        = 1;    // to enable input
    AudioUnitElement inputBus = 1;
    
    AudioUnitSetProperty (
                          *audioUnit,
                          kAudioOutputUnitProperty_EnableIO,
                          kAudioUnitScope_Input,
                          inputBus,
                          &enableInput,
                          sizeof (enableInput)
                          );
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = renderCallback; // Render function
    callbackStruct.inputProcRefCon = NULL;
    if(AudioUnitSetProperty(*audioUnit, kAudioOutputUnitProperty_SetInputCallback,
                            kAudioUnitScope_Global, 1, &callbackStruct,
                            sizeof(AURenderCallbackStruct)) != noErr) {
        return 1;
    }
    
    
    
    AudioStreamBasicDescription streamDescription;
    // You might want to replace this with a different value, but keep in mind that the
    // iPhone does not support all sample rates. 8kHz, 22kHz, and 44.1kHz should all work.
    streamDescription.mSampleRate = 44100;
    // Yes, I know you probably want floating point samples, but the iPhone isn't going
    // to give you floating point data. You'll need to make the conversion by hand from
    // linear PCM <-> float.
    streamDescription.mFormatID = kAudioFormatLinearPCM;
    // This part is important!
    streamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger |
    kAudioFormatFlagsNativeEndian |
    kAudioFormatFlagIsPacked;
    // Not sure if the iPhone supports recording >16-bit audio, but I doubt it.
    streamDescription.mBitsPerChannel = 16;
    // 1 sample per frame, will always be 2 as long as 16-bit samples are being used
    streamDescription.mBytesPerFrame = 2;
    // Record in mono. Use 2 for stereo, though I don't think the iPhone does true stereo recording
    streamDescription.mChannelsPerFrame = 1;
    streamDescription.mBytesPerPacket = streamDescription.mBytesPerFrame *
    streamDescription.mChannelsPerFrame;
    // Always should be set to 1
    streamDescription.mFramesPerPacket = 1;
    // Always set to 0, just to be sure
    streamDescription.mReserved = 0;
    
    // Set up input stream with above properties
    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Input, 0, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
    }
    
    
    // Ditto for the output stream, which we will be sending the processed audio to
    if(AudioUnitSetProperty(*audioUnit, kAudioUnitProperty_StreamFormat,
                            kAudioUnitScope_Output, 1, &streamDescription, sizeof(streamDescription)) != noErr) {
        return 1;
    }
    
    
    return 0;
}

- (void) resetData {
    inSync = false;
    dataCount = 0;
}

int startAudioUnit() {
    
    [refself resetData];
    //    memset(samples, 0, sizeof(int)*SAMPLES_BUFFER_SIZE);
    
    if(AudioUnitInitialize(*audioUnit) != noErr) {
        return 1;
    }
    
    if(AudioOutputUnitStart(*audioUnit) != noErr) {
        return 1;
    }

    return 0;
}


OSStatus renderCallback(void *userData, AudioUnitRenderActionFlags *actionFlags,
                        const AudioTimeStamp *audioTimeStamp, UInt32 busNumber,
                        UInt32 numFrames, AudioBufferList *buffers) {
    AudioBufferList bufferList;
    if(audioUnit == nil) {
        NSLog(@"nil audio unit");
        return noErr;
    }
    SInt16* samples = (SInt16*)malloc(numFrames*sizeof(SInt16)); // A large enough size to not have to worry about buffer overrun
    memset (&samples, 0, sizeof (samples));
    
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mData = samples;
    bufferList.mBuffers[0].mNumberChannels = 1;
    bufferList.mBuffers[0].mDataByteSize = numFrames*sizeof(SInt16);
    
    OSStatus status = AudioUnitRender(*audioUnit, actionFlags, audioTimeStamp,                                      1, numFrames, &bufferList);
    if(status != noErr) {
        NSLog(@"render error: %ld", status);
        return status;
    }
    SInt16 *inputFrames = (SInt16*)(bufferList.mBuffers[0].mData);
    fftPitch(numFrames, inputFrames);
    return noErr;
}

int stopProcessingAudio() {
    if(AudioOutputUnitStop(*audioUnit) != noErr) {
        return 1;
    }
    
    if(AudioUnitUninitialize(*audioUnit) != noErr) {
        return 1;
    }
    
    *audioUnit = NULL;
    return 0;
}



OSStatus fftPitch (UInt32 inNumberFrames, SInt16 *sampleBuffer) {
    static int callbackCount = 0;
    long fftSize = FFT_SIZE;
    
    
    // scope reference that allows access to everything in MixerHostAudio class
    int sampleRate =  44100.0;    // ;// Hertz
    
	uint32_t stride = 1;                    // interleaving factor for vdsp functions
	int bufferCapacity = fftBufferCapacity;    // maximum size of fft buffers
    float pitchShift = 1.0;                 // pitch shift factor 1=normal, range is .5->2.0
    long osamp = 4;                         // oversampling factor
    
	
	int frequency1, frequency2;                        // analysis frequency result
    
    
    //	ConvertInt16ToFloat
    
    vDSP_vflt16((SInt16 *) sampleBuffer, stride, (float *) analysisBuffer, stride, bufferCapacity );
    
    
    
    // YBA WINDOW
    
    /*
     
     FIR filter designed with
     http://t-filter.appspot.com
     
     sampling frequency: 41000 Hz
     
     * 0 Hz - 3000 Hz
     gain = 0
     desired attenuation = -40 dB
     actual attenuation = -40.51354624940917 dB
     
     * 3800 Hz - 6200 Hz
     gain = 5
     desired ripple = 5 dB
     actual ripple = 3.927693875608341 dB
     
     * 6900 Hz - 20000 Hz
     gain = 0
     desired attenuation = -40 dB
     actual attenuation = -40.51354624940917 dB
     
     */
    
#define FILTER_TAP_NUM 91
    
    static float filter_taps[FILTER_TAP_NUM] = {
        -0.0066742082277841805,
        0.00016292568542499564,
        0.00532965353296594,
        0.013183049039865098,
        0.011188991498769806,
        0.0028752982954490668,
        -0.013064018072085253,
        -0.018550955997817968,
        -0.013096740967646162,
        0.007187825927436339,
        0.018937945733027865,
        0.015748532664142407,
        -0.010966606132123129,
        -0.0321201616514399,
        -0.03133137355299769,
        0.010249543893432246,
        0.05983742907289521,
        0.08539635467820493,
        0.044865424166488845,
        -0.03924954823562882,
        -0.12483620805652669,
        -0.1375469553857056,
        -0.06738418531082115,
        0.05851739591127716,
        0.14823038640132666,
        0.15456910405586585,
        0.06699544727337564,
        -0.035681334669669065,
        -0.09415490251058208,
        -0.07074337266047283,
        -0.02509182005437459,
        -0.010197881198714488,
        -0.0646413657196786,
        -0.11816075263716454,
        -0.09514127032720857,
        0.062130112769454994,
        0.26731489315605483,
        0.3823753164977066,
        0.26127933940986464,
        -0.0675806621350142,
        -0.443283174561019,
        -0.6050268667948508,
        -0.4275997964508788,
        0.03275593172108161,
        0.4979091591413196,
        0.6995940985210207,
        0.4979091591413196,
        0.03275593172108161,
        -0.4275997964508788,
        -0.6050268667948508,
        -0.443283174561019,
        -0.0675806621350142,
        0.26127933940986464,
        0.3823753164977066,
        0.26731489315605483,
        0.062130112769454994,
        -0.09514127032720857,
        -0.11816075263716454,
        -0.0646413657196786,
        -0.010197881198714488,
        -0.02509182005437459,
        -0.07074337266047283,
        -0.09415490251058208,
        -0.035681334669669065,
        0.06699544727337564,
        0.15456910405586585,
        0.14823038640132666,
        0.05851739591127716,
        -0.06738418531082115,
        -0.1375469553857056,
        -0.12483620805652669,
        -0.03924954823562882,
        0.044865424166488845,
        0.08539635467820493,
        0.05983742907289521,
        0.010249543893432246,
        -0.03133137355299769,
        -0.0321201616514399,
        -0.010966606132123129,
        0.015748532664142407,
        0.018937945733027865,
        0.007187825927436339,
        -0.013096740967646162,
        -0.018550955997817968,
        -0.013064018072085253,
        0.0028752982954490668,
        0.011188991498769806,
        0.013183049039865098,
        0.00532965353296594,
        0.00016292568542499564,
        -0.0066742082277841805
    };


 
  //    vDSP_desamp(analysisBuffer, stride, filter_taps, analysisBuffer, bufferCapacity, FILTER_TAP_NUM);

//    vDSP_hann_window(analysisBuffer, bufferCapacity, vDSP_HANN_NORM);

  
    
    pitchShift = 1;
    
    // osamp should be at least 4, but at this time my ipod touch gets very unhappy with
    // anything greater than 2
    
    osamp = 4;
    fftSize = FFT_SIZE;//1024;		// this seems to work in real time since we are actually doing the fft on smaller windows
    if(inSync) {
        memcpy((recordBuffer+(callbackCount*inNumberFrames)), analysisBuffer, inNumberFrames*sizeof(float));
        callbackCount++;
        if(callbackCount == (int)(REC_DURATION/SLOT_DURATION)) { //
            inSync = NO;
                for(int i=0;i<callbackCount;i++) {
                    memcpy(analysisBuffer, (recordBuffer+(i*inNumberFrames)), inNumberFrames*(sizeof(float)));
                    float* buff = data[i];
                    yba2Spectrogram( pitchShift , (long) inNumberFrames,
                                   fftSize,  osamp, (float) sampleRate,
                                   (float*)analysisBuffer ,  (float*)outputBuffer,
                                   fftSetup, buff, freqs);
                }
                [refself decode];
                callbackCount = 0;
        }
    }
    else {
        int syncCount = 0;
        for(int i=0;i<NUMBER_OF_HARMONIES;i++) {
            int frequency;
            int harmony = HARMONIES[i];
            yba2PitchShift( pitchShift , (long) inNumberFrames,
                       fftSize,  osamp, (float) sampleRate,
                       (float*)analysisBuffer ,  (float*)outputBuffer,
                       fftSetup, &frequency, &frequency2, TONE_A*harmony-100*harmony);
            int freq = ROUND_FREQ(frequency/harmony, 10);
            //NSLog(@"freq: %d, prev: %d", freq, prevFreq);
            if((freq == TONE_A || freq == TONE_B || freq == TONE_C) &&
               (prevFreq == TONE_A || prevFreq == TONE_B || prevFreq == TONE_C)) {
                syncCount++;
            }
            if(syncCount >= MIN_SYNC_HARMONIES) {
                inSync =  YES;
                syncOffset = freq - TONE_A;
                callbackCount = 0;
                dataCount = 0;
            }
            prevFreq = freq;
        }
    }
    
    return noErr;

    
}


/*
void add_sample(int freq1, int freq2, double sample_time) {
    double rts = relative_timestamp();
    if( freq1 < TONE_A || freq1 > TONE_MAX) {
        freq1 = freq2;
    }

        //NSLog(@"Added: %d, %d,  %lf", freq1, freq2, rts);
        samples1[samples_index%SAMPLES_BUFFER_SIZE] = freq1;
        samples2[samples_index%SAMPLES_BUFFER_SIZE] = freq2;
        samples3[(samples_index*2)%SAMPLES_BUFFER_SIZE] = freq1;
        samples3[(samples_index*2+1)%SAMPLES_BUFFER_SIZE] = freq2;
        
        samples_time[samples_index%SAMPLES_BUFFER_SIZE] = sample_time;
        samples_index++;

    
}
*/

- (bool) decode {
    self.crc = 0;
    self.expected_crc = 1;
    int harmonies[3] = {3,1,5};
    float** originalData = data;
    highpassFilter(MIN_FREQ);
//    nFilter(7);
    
    for(int i=0;i<3;i++) {
        data = getDataCopy();

        harmonicFilter(harmonies[i]);
        bandFilter();
        compactLeft();
        compactLeft();
        decodeSpectrogram();
        bool res =  [self singleDecode] || [self multiDecode];
        if(res) {
            NSLog(@"Decoded with harmony %d", harmonies[i]);
            [delegate performSelectorOnMainThread:@selector(ProtocolDecoderFinished) withObject:self waitUntilDone:YES];
            freeDataCopy(data);
            data = originalData;
            return YES;
        }
        harmonicFilter(1.0/harmonies[i]); // unfilter
        freeDataCopy(data);
        data = originalData;

    }
    if(demoMode) {
        self.crc = self.expected_crc;
        self.battery = 0;
        self.error = 0;
        if(self.glucose > 150 || self.glucose < 60) {
            self.glucose = 60+(arc4random()%40);
        }
    }
   //  [delegate performSelectorOnMainThread:@selector(ProtocolDecoderFinished) withObject:self waitUntilDone:YES];
   // printSpectrogram();
    return NO;
}

void printSpectrogram() {
    int size = (int)(REC_DURATION/SLOT_DURATION);
    for(int j=0;j<MAX_FRAME_LENGTH;j++) { // j Iterate frequencies
        float freq = freqs[j];
        if (freq < MIN_FREQ || freq > MAX_FREQ) {
            continue;
        }
        printf("%f, ", freq);
        for(int i=1;i<size;i++) { // i iterates time
            float tmp = data[i][j];
            printf("%f, ", tmp);
        }
        printf("\n");
    }
}


void bandFilter() {
    int size = (int)(REC_DURATION/SLOT_DURATION);
    for(int j=0;j<MAX_FRAME_LENGTH;j++) { // j Iterate frequencies
        float freq = freqs[j];
        if (freq < MIN_FREQ || freq > MAX_FREQ) {
            for(int i=1;i<size;i++) { // i iterates time
                data[i][j] = 0;
            }
        }
    }
}

void highpassFilter(int threshold) {
    int size = (int)(REC_DURATION/SLOT_DURATION);
    for(int j=0;j<MAX_FRAME_LENGTH;j++) { // j Iterate frequencies
        float freq = freqs[j];
        if (freq < threshold) {
            for(int i=1;i<size;i++) { // i iterates time
                data[i][j] = 0;
            }
        }
    }
}



void addCompactedFreq(float freq, float val, float* newFreqs, float*newData, int binSize) {
    int bins = 1+(MAX_FREQ - MIN_FREQ)/binSize;
    for(int i=0;i<bins;i++) {
        float adjustedFreq = newFreqs[i];
        float distance = abs(adjustedFreq - freq);
        if(distance < binSize) {
            float factor = 1.0/(distance+1);
            newData[i] += factor*val;
        }
    }
}

void decodeSpectrogram() {
    int size = (int)(REC_DURATION/SLOT_DURATION);
    memset(samples, 0, SAMPLES_BUFFER_SIZE*sizeof(int));
    for(int i=0;i<size;i++) { // i iterates time
        float maxVal = -1;
        int freq = 0;
        for(int j=0;j<MAX_FRAME_LENGTH;j++) { // j Iterate frequencies
            if(maxVal < data[i][j]) {
                maxVal = data[i][j];
                freq = (int)freqs[j];
                
            }
        }
        samples[i] = freq;
    }
}



void matrixMul(int matrix[3][3], float norm) {
    int size = (int)(REC_DURATION/SLOT_DURATION);
    float** dataCopy = getDataCopy();
    for(int j=1;j<MAX_FRAME_LENGTH-1;j++) { // j Iterate frequencies
        data[0][j] = 0; // clear first timeslot
        float freq = freqs[j];
        if (freq < MIN_FREQ || freq > MAX_FREQ) {
            continue;
        }
        for(int i=1;i<size-1;i++) { // i iterates time
            float sum=0;
            for(int x=0;x<3;x++) {
                for(int y=0;y<3;y++) {
                    sum += matrix[x][y]*dataCopy[i-1+x][j-1+y];
                }
            }
            sum *= norm;
            data[i][j] = MAX(sum,0);
        }
    }
    freeDataCopy(dataCopy);
    
}

float** getDataCopy() {
    int size = (int)(REC_DURATION/SLOT_DURATION);
    float** dataCopy = malloc(size*sizeof(float*));
    for(int i=0;i<size;i++) {
        float* buff = malloc(MAX_FRAME_LENGTH*sizeof(float));
        memcpy(buff, data[i], MAX_FRAME_LENGTH*sizeof(float));
        dataCopy[i] = buff;
    }
    return dataCopy;
    
}

void nFilter(int n) {
    int size = (int)(REC_DURATION/SLOT_DURATION);
    for(int i=0;i<size;i++) {
        float* timeslot = data[i];
        float* copy = malloc(MAX_FRAME_LENGTH*sizeof(float));
        memcpy(copy, timeslot, MAX_FRAME_LENGTH*sizeof(float));
        qsort(copy, MAX_FRAME_LENGTH, sizeof(float), floatcomp);
        float threshold =copy[n];
        for(int j=0;j<MAX_FRAME_LENGTH;j++) {
            if(timeslot[j] < threshold) {
                timeslot[j] = 0;
            }
        }
    }
    
}

int floatcomp(const void* elem1, const void* elem2)
{
    if(*(const float*)elem1 > *(const float*)elem2)
        return -1;
    return *(const float*)elem1 < *(const float*)elem2;
}


float** getIDMatrix() {
    int size = (int)(REC_DURATION/SLOT_DURATION);
    float** dataCopy = malloc(size*sizeof(float*));
    for(int i=0;i<size;i++) {
        float* buff = malloc(MAX_FRAME_LENGTH*sizeof(float));
        for(int j=0;j<MAX_FRAME_LENGTH;j++) {
            buff[j] = 0;
            if(i%20==0) {
//                NSLog(@"%d, %d is 1", i, j);
                buff[j] = 1.0;
            }
        }
        dataCopy[i] = buff;
    }
    return dataCopy;
    
}


void compactLeft() {
    int matrix[3][3] = {{0,0,0}, {0,2,0}, {0,1,0}};
    float norm = 1/3.0;
    matrixMul(matrix, norm);
}

void gaussianBlur() {
    int matrix[3][3] = {{0,0,0}, {1,2,1}, {0,0,0}};
    float norm = 1/4.0;
    matrixMul(matrix, norm);
}

void sharpen() {
    int matrix[3][3] = {{0,-1,0}, {-1,5,-1}, {0,-1,0}};
    float norm = 1/25.0;
    matrixMul(matrix, norm);
}

void enhance() {
    int matrix[3][3] = {{0,1,0}, {1,4,1}, {0,1,0}};
    float norm = 1/8.0;
    matrixMul(matrix, norm);
}

void sobel() {
        int matrix[3][3] = {{0,1,-1}, {2,0,-2}, {1,0,-1}};
    float norm = 1/16.0;
    matrixMul(matrix, norm);
    
}

void edgeDetect() {
    int matrix[3][3] = {{0,1,0}, {1,-4,1}, {0,1,0}};
    float norm = 1/16.0;
    matrixMul(matrix, norm);
}

void freeDataCopy(float** dataCopy) {
    int size = (int)(REC_DURATION/SLOT_DURATION);
    for(int i=0;i<size;i++) {
        free(dataCopy[i]);
    }
    free(dataCopy);
}

void dataEstimator() {
    int size = (int)(REC_DURATION/SLOT_DURATION);
    float** dataCopy = getDataCopy();
    for(int j=1;j<MAX_FRAME_LENGTH-1;j++) { // j Iterate frequencies
        data[0][j] = 0; // clear first timeslot
        float freq = freqs[j];
        if (freq < MIN_FREQ || freq > MAX_FREQ) {
            continue;
        }
        for(int i=1;i<size-1;i++) { // i iterates time
            float prevMag = dataCopy[i-1][j];
            float mag = dataCopy[i][j];
            float val = 0;
            if(prevMag != 0 && mag != 0) {
                val =  70-abs((int)(10*log10(mag)-10*log10(prevMag)));
            }
            data[i][j] = val;
        }
    }
    freeDataCopy(dataCopy);
}


- (bool) singleDecode {
    int* buffs[1] = {samples};
    bool seqs[2] = {false, true};
    
    int rounds[3] = {50,25,10};
    for(int b=0;b<1;b++) {
        for(int s=0;s<2;s++) {
            for(int r =0; r < 3;r++) {
                if([self decode:buffs[b] onlySequances:seqs[s] round:rounds[r]]) {
                    NSLog(@"SD success with buff: %d", (b+1));
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (bool) decode:(int*)buffer onlySequances:(bool)onlySequances round:(int)round  {
    NSString* msg = @"";
    //NSLog(@"Decode with: %d, %d", onlySequances, round);
    NSMutableString* res = [[NSMutableString alloc] init];
    int decoded=0;
    int prevFreq = 0;
    for(int i=0;i<SAMPLES_BUFFER_SIZE;i++) {
        int prevIndex = (i-1);
        int freq = ROUND_FREQ(buffer[i], round);
        if(freq < MIN_FREQ || freq > MAX_FREQ) {
            continue;
        }
        if(onlySequances && prevIndex != -1 && freq != ROUND_FREQ(buffer[prevIndex], round)) {
            continue;
        }
        if(freq == TONE_A || freq == TONE_B || freq == TONE_C)
           
        {
            NSLog(@"DETECTED SYC #2, %d", freq);
            decoded = 0;
            prevFreq = freq;
            syncOffset = freq - TONE_A;
            res = [[NSMutableString alloc] init];
            msg = @"";
            continue;
        }
        int offsetFreq = freq-syncOffset;
        if(offsetFreq == TONE_Q || freq == prevFreq) {
            prevFreq = freq;
            continue;
        }
        prevFreq = freq;
        NSString* bin = [TONES objectForKey:[NSNumber numberWithInteger:offsetFreq]];
        if(bin == nil) {continue;}
        else {
            [res appendString:bin];
            decoded++;
        }
        //NSLog(@"Decode %d) %d %d, %@ %lf %d", i, freq, offsetFreq, bin, (samples_time[i]-samples_time
//              [i-1]), decoded);
            msg =   [[NSString alloc] initWithFormat:@"%@\nDecode %d offset %d, bin %@", msg, offsetFreq,freq-offsetFreq, bin];
        if (decoded == DATA_LENGTH) {
            NSString* candidates[1] = {[[NSString alloc] initWithString:res]};//,[self uidHeuristic:res]};
            for(int i=0;i<1;i++) {
                res = candidates[i];

            [self resetData];
            self.uid = to_dec([res substringWithRange:NSMakeRange(0, UID_LENGTH)]);
            self.error = to_dec([res substringWithRange:NSMakeRange(UID_LENGTH,ERROR_LENGTH)]);
            self.battery = to_dec([res substringWithRange:NSMakeRange(UID_LENGTH+ERROR_LENGTH, BATTERY_LENGTH)]);
            self.glucose = to_dec([res substringWithRange:NSMakeRange(UID_LENGTH+ERROR_LENGTH+BATTERY_LENGTH, GLUCOSE_LENGTH)]);
            self.crc = to_dec([res substringWithRange:NSMakeRange(UID_LENGTH+ERROR_LENGTH+BATTERY_LENGTH+GLUCOSE_LENGTH, CRC_LENGTH)]);
            NSString* data =[res substringWithRange:NSMakeRange(0,UID_LENGTH+ERROR_LENGTH+BATTERY_LENGTH+GLUCOSE_LENGTH)];
            NSString* expected = [NSString stringWithCString:MakeCRC([data UTF8String])  encoding:NSUTF8StringEncoding];
            self.expected_crc = to_dec(expected);
            if(self.crc == self.expected_crc) {
                //NSLog(@">>>> MATCH with sync ofset %d", syncOffset);
                //      [delegate performSelectorOnMainThread:@selector(Log:) withObject:msg waitUntilDone:NO];
//                [delegate performSelectorOnMainThread:@selector(ProtocolDecoderFinished) withObject:self waitUntilDone:YES];
                return YES;
            }
            }
        }
    }
    return NO;

    
}



-(NSString*) uidHeuristic:(NSString*)str {
    NSString* default_uid = @"0111101100";
    NSString* res = [str stringByReplacingCharactersInRange:NSMakeRange(0, [default_uid length]) withString:default_uid];
    NSLog(res);
    return res;
}


//////////////////////////////////////////////////
// Setup FFT - structures needed by vdsp functions
//
void setupFFT() {
	
	// I'm going to just convert everything to 1024
	
	
	// on the simulator the callback gets 512 frames even if you set the buffer to 1024, so this is a temp workaround in our efforts
	// to make the fft buffer = the callback buffer,
	
	
	// for smb it doesn't matter if frame size is bigger than callback buffer
	
	UInt32 maxFrames = FFT_SIZE;//1024;    // fft size
	
	
	// setup input and output buffers to equal max frame size
	
	//dataBuffer = (void*)malloc(maxFrames * sizeof(SInt16));
	outputBuffer = (float*)malloc(maxFrames *sizeof(float));
	analysisBuffer = (float*)malloc(maxFrames *sizeof(float));
    recordBuffer =(float*)malloc(300*maxFrames *sizeof(float));

	
	// set the init stuff for fft based on number of frames
	
	fftLog2n = log2f(maxFrames);		// log base2 of max number of frames, eg., 10 for 1024
	fftN = 1 << fftLog2n;					// actual max number of frames, eg., 1024 - what a silly way to compute it
    
    
	fftNOver2 = maxFrames/2;                // half fft size
	fftBufferCapacity = maxFrames;          // yet another way of expressing fft size
	fftIndex = 0;                           // index for reading frame data in callback
	
	// split complex number buffer
	fftA.realp = (float *)malloc(fftNOver2 * sizeof(float));		//
	fftA.imagp = (float *)malloc(fftNOver2 * sizeof(float));		//
	
	
	// zero return indicates an error setting up internal buffers
	
	fftSetup = vDSP_create_fftsetup(fftLog2n, FFT_RADIX2);
    if( fftSetup == (FFTSetup) 0) {
        NSLog(@"Error - unable to allocate FFT setup buffers" );
	}
	
}

void initTones() {
    TONES = [[NSMutableDictionary alloc] init];
    int n = pow(2,BITS_PER_TONE);
    for(int i=0;i<n;i++) {
        NSString* value = to_bin(i,BITS_PER_TONE);
        NSInteger  key = ((int)(TONE_MIN + i*TONE_SHIFT + TONE_SHIFT/2)/TONE_SHIFT)*TONE_SHIFT;
        [TONES setObject:value forKey:[NSNumber numberWithInteger:key]];
    }
}

int to_dec(NSString* b) {
    int res =(int) strtol([b UTF8String], NULL, 2);
    return res;
}

NSString * to_bin( int number , int len)
{
    NSMutableString * string = [[NSMutableString alloc] init];
    
    int width = len;
    int binaryDigit = 0;
    int integer = number;
    
    while( binaryDigit < width )
    {
        binaryDigit++;
        
        [string insertString:( (integer & 1) ? @"1" : @"0" )atIndex:0];
        
        
        integer = integer >> 1;
    }
    
  
    return string;
}


char*  MakeCRC(const char *BitString)
{
    //NSLog(@"%@",[NSString stringWithCString:BitString encoding:NSUTF8StringEncoding]);
    
    int res = 0;
    static char Res[9];                                 // CRC Result
    char CRC[8];
    int  i;
    char DoInvert;
    
    for (i=0; i<8; ++i)  CRC[i] = 0;                    // Init before calculation
    
    for (i=0; i<strlen(BitString); ++i)
    {
        DoInvert = ('1'==BitString[i]) ^ CRC[7];         // XOR required?
        
        CRC[7] = CRC[6];
        CRC[6] = CRC[5];
        CRC[5] = CRC[4];
        CRC[4] = CRC[3];
        CRC[3] = CRC[2];
        CRC[2] = CRC[1];
        CRC[1] = CRC[0];
        CRC[0] = DoInvert;
    }
    
    for (i=0; i<8; ++i)  Res[7-i] = CRC[i] ? '1' : '0'; // Convert binary to ASCII
    Res[8] = 0;                                         // Set string terminator
    for(int i=0;i<9;i++) {
        res += Res[i]*pow(2,8-i);
    }
    return Res;
}

- (void) initParams {
    
    TONE_SHIFT = 50;
    BITS_PER_TONE = 4;
    FFT_SIZE = 4096;
    SLOT_DURATION = 0.023f;
    REC_DURATION = 2.5; //3*15*0.05;
    ROUND = 25;
    
    UID_LENGTH = 8;
    ERROR_LENGTH = 1;
    BATTERY_LENGTH = 1;
    GLUCOSE_LENGTH  = 10;
    CRC_LENGTH = 8;
    
    
    NUMBER_OF_HARMONIES = 3;
    MIN_SYNC_HARMONIES = 1;
    HARMONIES = malloc(sizeof(int)*NUMBER_OF_HARMONIES);
    HARMONIES[0] = 3;
    HARMONIES[1] = 1;
    HARMONIES[2] = 5;
    
    

    [self calcParams];
}

- (void) calcParams {

    TONE_A = 3600;
    TONE_B  = (TONE_A+TONE_SHIFT);
    TONE_C  = (TONE_B+TONE_SHIFT);
    TONE_Q = (TONE_C + TONE_SHIFT);
    TONE_MIN = (TONE_Q+TONE_SHIFT);
    DATA_LENGTH  = ((UID_LENGTH+ERROR_LENGTH+BATTERY_LENGTH+GLUCOSE_LENGTH+CRC_LENGTH+BITS_PER_TONE-1)/BITS_PER_TONE);

    TONE_MAX = TONE_MIN+TONE_SHIFT*(pow(2,BITS_PER_TONE)) + 3*TONE_SHIFT;

}



double relative_timestamp() {
    static double prevTime = -1;
    struct timeval tv;
    gettimeofday(&tv,NULL);
    double perciseTimeStamp = tv.tv_sec + tv.tv_usec * 0.000001;
    if(prevTime == -1) {
        prevTime = perciseTimeStamp;
        return -1;
    }
    double res = perciseTimeStamp - prevTime;
    prevTime = perciseTimeStamp;
    return res;
}


double timestamp() {
    struct timeval tv;
    gettimeofday(&tv,NULL);
    double perciseTimeStamp = tv.tv_sec + tv.tv_usec * 0.000001;
    return perciseTimeStamp;
}



- (NSString*)getErrorMessage:(int)errorId {
    
    typedef enum {
        ERR_NONE,               // 0 no problem
        ERR_TEMPERATURE,		//1 out of range 10~40 degrees
       	ERR_INVALID_STRIP,		//2 reused strip
       	ERR_REMOVE_STRIP,		//3 removed strip during measurement
        ERR_MEASUREMENT,		//4 out of range DC 310mV +/- 6mV?
        ERR_SYSTEM,			//5 abnormal temperature & battery voltage
        ERR_LOWEST,			//6 glucose is under 3
        ERR_INSUFFICIENT_BLOOD,		//7 blood check once, but not detect blood
        ERR_WRONG_BLOOD_DIRECTION,	//8 blood direction error
        ERR_BLOOD_INSERTION_TIMEOUT,	//9   time out 60sec of input blood
    } ErrorCode_t;
    
    
    
    NSMutableArray* messages = [[NSMutableArray alloc] initWithObjects:
                                @"General Error" //      0  ERR_NONE,
                                @"General error. The meter is too hot or cold.", // 1 ERR_TEMPERATURE
                                @"Used test strip was inserted into the test port.", // 2 ERR_INVALID_STRIP
                                @"Test strip is damaged or was removed too soon.", // 3 ERR_REMOVE_STRIP
                                @"The sample was improperly applied or there was electronic interference during the test.", //4 ERR_MEASUREMENT
                                @"Internal error – cannot read test strip.", // 5 ERR_SYSTEM
                                @"Internal error – cannot read test strip.", // 6 ERR_LOWEST
                                @"Inserted blood is less than standard.", // 7 ERR_INSUFFICIENT_BLOOD
                                @"Blood was applied to the wrong part of the test strip.", // 8 ERR_WRONG_BLOOD_DIRECTION
                                @"Blood was not applied on the test strip.", // 9 ERR_BLOOD_INSERTION_TIMEOUT
                                nil];
    
    if(errorId <= messages.count) {
        return (NSString*)[messages objectAtIndex:errorId];
    }
    return nil;
}
int ROUND_FREQ(int x, int r) {
    int tmp =  (((int)x+r/2)/r)*r;
    return tmp;
}




- (bool) multiDecode {
    int* buffs[1] = {samples};
    bool seqs[2] = {false, true};
    
    int rounds[4] = {50};//,25,10,5};
    for(int i=0;i<1;i++) {
        for(int s=0;s<2;s++) {
            for(int r =0; r < 1;r++) {
                int result[SAMPLES_BUFFER_SIZE];
                int a[SAMPLES_BUFFER_SIZE];
                int b[SAMPLES_BUFFER_SIZE];
                int c[SAMPLES_BUFFER_SIZE];
                memset(result, NO_SAMPLE, SAMPLES_BUFFER_SIZE*sizeof(int));
                memset(a, NO_SAMPLE, SAMPLES_BUFFER_SIZE*sizeof(int));
                memset(b, NO_SAMPLE, SAMPLES_BUFFER_SIZE*sizeof(int));
                memset(c, NO_SAMPLE, SAMPLES_BUFFER_SIZE*sizeof(int));
                fillMDBuffers(buffs[i], a, b, c);
                normalizeOffset(b, TONE_SHIFT);
                normalizeOffset(c, 2*TONE_SHIFT);
                int result_index = 0;
                int a_index = 0;
                int b_index = 0;
                int c_index = 0;
                if(multiDecodeStep(result, a, b, c, &result_index, &a_index, &b_index, &c_index, buffs[i], seqs[s], rounds[r], false)) {
                    NSLog(@"MD success");
                    return YES;
                }
            }
        }
    }
    return NO;
}

bool multiDecodeStep(int *result, int* a, int* b, int *c, int* result_index, int* a_index,int* b_index,int* c_index, int* input, bool seq, int round, bool reachedEnd) {
    //NSLog(@"MD indices (%d %d, %d, %d), seq %d, round %d", *a_index, *b_index, *c_index, *result_index, seq, round);
    if(*result_index != 0 && result[(*result_index)-1] == 0) {
        return [refself decode:result onlySequances:seq round:round];
    }
    int candidates[3];
    memset(candidates, NO_SAMPLE, 3*sizeof(int));

    
    //@TODO do I need to re-use decode candidates ?
    if(!reachedEnd) {
        multiDecodeCandidates(candidates, a,b,c,a_index, b_index, c_index);
    }
    NSLog(@"Finished candidates");
    int current_result_index = (*result_index);
    int current_a_index = *a_index;
    int current_b_index= *b_index;
    int current_c_index = *c_index;

    for(int i=0;i<3;i++) {
        if(i > 0 && candidates[i] == NO_SAMPLE) { // avoid 2nd and 3rd options when there is only one good
            continue;
        }
        result[current_result_index] = candidates[i];
        *result_index = (*result_index)+1;
        if(multiDecodeStep(result, a, b, c, result_index, a_index, b_index, c_index, input, seq, round, reachedEnd)) {
            return YES;
        }
     //   NSLog(@"REACHED END WITH %d", *result_index);
        reachedEnd = true;
        *a_index = current_a_index;
        *b_index = current_b_index;
        *c_index = current_c_index;
        *result_index = current_result_index;
    }
    return NO;
}

void multiDecodeCandidates(int* candidates, int* a, int*b, int* c, int* a_index, int* b_index, int* c_index) {
    int maj = majority(a[*a_index], b[*b_index], c[*c_index]) ;
    //NSLog(@"Maj of %d, %d, %d is %d",a[*a_index],b[*b_index], c[*c_index], maj);
    if(maj != -1) {
        candidates[0] = maj;
        candidates[1] = 0;
        candidates[2] = 0;
    }
    else {
        candidates[0] = a[*a_index];
        candidates[1] = b[*b_index];
        candidates[2] = c[*c_index];
    }
    (*a_index)++;
    (*b_index)++;
    (*c_index)++;

}

int majority(int a, int b, int c) {
    if(a==b || a == c) {
        return a;
    }
    if(b==c) {
        return b;
    }
    return -1;
}
    



void fillMDBuffers(int* input, int* a, int* b, int* c) {
    int* currBuff = a;
    int index = 0;
    bool isDone = false;
    for(int i=0;i<SAMPLES_BUFFER_SIZE;i++ ) {
        int freq = ROUND_FREQ(input[i], 50);
//        NSLog(@"analyzie: %d, %d, %d", i, index, freq);
        if(freq == TONE_A && currBuff != a) {
            if(isDone) {return;}//
            NSLog(@"Buff A");
            index = 0;
            continue;
        }
        else if(freq == TONE_B && currBuff != b) {
            if(isDone) {return;}
            NSLog(@"Buff B");
            currBuff = b;
            index = 0;
            continue;
        }
        else if(freq == TONE_C && currBuff != c) {
            isDone = true;
           NSLog(@"Buff C");
            currBuff = c;
            index = 0;
            continue;
        }
        
        // avoid sync at the begining of the buff
        if(index ==0 && (freq == TONE_A || freq == TONE_B || freq == TONE_C)) {
            continue;
        }

            NSLog(@"buff[%d]=%d", index, freq);
            currBuff[index] = freq;
            index++;

        
    }
}

void normalizeOffset(int* x, int offset) {
    int i=0;
    while(x[i] != 0) {
        x[i] -= offset;
        i++;
    }
}

void harmonicFilter(float harmony) {

     for(int j=0;j<MAX_FRAME_LENGTH;j++) {
//         NSLog(@"Harmony filter: %f/%d=%f", freqs[j], harmony, (freqs[j] / harmony));
         freqs[j] = freqs[j] / harmony;

     }
}


@end

