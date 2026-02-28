
#include "../audiodrv/CoreAudioDriver.h"

@interface AVEngineWrapper : NSObject
- (instancetype)initWithSampleRate:(double)rate bufferSize:(unsigned int)size owner:(CoreAudioStream *)owner;
- (void)start;
- (void)stop;
@end
