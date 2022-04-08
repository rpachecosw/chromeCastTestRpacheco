//
//  CustomControlsView.swift
//  chromeCastTestRpacheco
//
//  Created by Richard Pacheco on 4/5/22.
//

import SwiftUI

struct CustomControlsView: View {
    @ObservedObject var playerVM: PlayerViewModel
    
    var body: some View {
        HStack {
            if playerVM.isPlaying == false {
                Button(action: {
                    playerVM.player.play()
                }, label: {
                    Image(systemName: "play.circle")
                        .imageScale(.large)
                })
            } else {
                Button(action: {
                    playerVM.player.pause()
                }, label: {
                    Image(systemName: "pause.circle")
                        .imageScale(.large)
                })
            }
            
            if let duration = playerVM.duration {
                Slider(value: $playerVM.currentTime, in: 0...duration, onEditingChanged: { isEditing in
                    playerVM.isEditingCurrentTime = isEditing
                })
            } else {
                Spacer()
            }
        }
        .padding()
        .background(.thinMaterial)
    }
}
