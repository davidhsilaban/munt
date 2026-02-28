//
//  AudioSessionManager.h
//  mt32emu-qt
//
//  Created by David Silaban on 10/06/25.
//
#ifndef AUDIOSESSIONMANAGER_H
#define AUDIOSESSIONMANAGER_H

#ifdef __cplusplus
extern "C" {
#endif

void setupAudioSession();
void startBgTask();
void stopBgTask();

#ifdef __cplusplus
}
#endif

#endif // AUDIOSESSIONMANAGER_H
