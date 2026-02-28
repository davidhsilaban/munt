
// AVEngineWrapper.mm
#import <AVFoundation/AVFoundation.h>
#import "AVEngineWrapper.h"

extern "C" {

void *AVEngine_Create(double sampleRate, unsigned int bufferSize, CoreAudioStream *owner) {
    return (__bridge_retained void *)[[AVEngineWrapper alloc] initWithSampleRate:sampleRate bufferSize:bufferSize owner:owner];
}

void AVEngine_Start(void *engine) {
    AVEngineWrapper *wrapper = (__bridge AVEngineWrapper *)engine;
    [wrapper start];
}

void AVEngine_Stop(void *engine) {
    AVEngineWrapper *wrapper = (__bridge AVEngineWrapper *)engine;
    [wrapper stop];
}

void AVEngine_Destroy(void *engine) {
    CFRelease(engine);
}

}

@interface AVEngineWrapper ()
@property AVAudioEngine *engine;
@property AVAudioPlayerNode *playerNode;
@property double sampleRate;
@property unsigned int bufferSize;
@property CoreAudioStream *owner;
@property AVAudioPCMBuffer *pcmBuffer;
@end

@implementation AVEngineWrapper

- (instancetype)initWithSampleRate:(double)rate bufferSize:(unsigned int)size owner:(CoreAudioStream *)owner {
    self = [super init];
    self.engine = [[AVAudioEngine alloc] init];
    self.playerNode = [[AVAudioPlayerNode alloc] init];
    self.sampleRate = rate;
    self.bufferSize = size;
    self.owner = owner;
    return self;
}

- (void)start {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];

    AudioStreamBasicDescription dataFormat = {(Float64)self.sampleRate, kAudioFormatLinearPCM, kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsSignedInteger, 4, 1, 4, 2, 16, 0};
//    AVAudioFormat *format = [[AVAudioFormat alloc] initWithStreamDescription:&dataFormat];
    AVAudioFormat *format = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32 sampleRate:self.sampleRate channels:2 interleaved:YES];
    AVAudioMixerNode *mixerNode = self.engine.mainMixerNode;
    [self.engine attachNode:self.playerNode];
    [self.engine connect:self.playerNode to:mixerNode format:format];
    [self.engine startAndReturnError:nil];
    [self.playerNode play];
    
    [self scheduleNextBuffer];
}

- (void)scheduleNextBuffer {
    AudioStreamBasicDescription dataFormat = {(Float64)self.sampleRate, kAudioFormatLinearPCM, kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsSignedInteger, 4, 1, 4, 2, 16, 0};
    AVAudioFormat *format = [[AVAudioFormat alloc] initWithStreamDescription:&dataFormat];
    uint frameCount = self.bufferSize / sizeof(int16_t) / 2; // Stereo
    if (_pcmBuffer == nil) {
        _pcmBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:frameCount];
    }
    _pcmBuffer.frameLength = frameCount;

    int16_t *buffer = _pcmBuffer.int16ChannelData[0];
//    [self.owner renderOutputBuffer:buffer frameCount:frameCount];
//    self.owner->renderOutputBufferAV(buffer, frameCount);

    __weak typeof(self) weakSelf = self;
//    [self.playerNode scheduleBuffer:_pcmBuffer completionHandler:^{
////        [weakSelf scheduleNextBuffer];
//    }];
}

- (void)stop {
    [self.playerNode stop];
    [self.engine stop];
}

@end
