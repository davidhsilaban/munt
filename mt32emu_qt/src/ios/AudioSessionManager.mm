//
//  AudioSessionManager.m
//  mt32emu-qt
//
//  Created by David Silaban on 10/06/25.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

static UIBackgroundTaskIdentifier bgTask = UIBackgroundTaskInvalid;

extern "C" {
    void startBgTask() {
        bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
    }
    
    void stopBgTask() {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }
    
    void setupAudioSession() {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error = nil;
        
        [[NSNotificationCenter defaultCenter] addObserverForName:AVAudioSessionSilenceSecondaryAudioHintNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            NSLog(@"AVAudioSessionSilenceSecondaryAudioHintNotification");
        }];
        
        //    [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
        [session setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:(AVAudioSessionCategoryOptionMixWithOthers) error:&error];
        
        if (error) {
            NSLog(@"Error setting category: %@", error.localizedDescription);
        }
        
        [session setActive:YES error:&error];
        if (error) {
            NSLog(@"Error activating session: %@", error.localizedDescription);
        }
    }
}

