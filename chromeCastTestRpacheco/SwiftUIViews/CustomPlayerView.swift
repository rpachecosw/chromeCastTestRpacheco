//
//  CustomPlayerView.swift
//  chromeCastTestRpacheco
//
//  Created by Richard Pacheco on 4/5/22.
//

import SwiftUI
import AVFoundation

enum CastSessionStatus {
    case started
    case resumed
    case ended
    case failedToStart
    case alreadyConnected
}

struct CustomPlayerView: View {
    @StateObject private var playerVM = PlayerViewModel()
    @State private var playlist: [Media] = Media.playlist
    
    init() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
            try audioSession.setActive(true)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                CustomVideoPlayer(playerVM: playerVM)
                    .overlay(CustomControlsView(playerVM: playerVM)
                             , alignment: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .padding()
            .overlay(playerVM.isInPipMode ? List(playlist) { media in
                Button(media.title) {
                    playerVM.setCurrentItem(media)
                }
            } : nil)
            
            Button(action: {
                withAnimation {
                    playerVM.isInPipMode.toggle()
                }
            }, label: {
                if playerVM.isInPipMode {
                    Label("Stop PiP", systemImage: "pip.exit")
                } else {
                    Label("Start PiP", systemImage: "pip.enter")
                }
            })
            .padding()
        }
        .padding()
        .onAppear {
            playerVM.setCurrentItem(playlist.first!)
            playerVM.player.play()
        }
        .onDisappear {
            playerVM.player.pause()
        }
    }
}
