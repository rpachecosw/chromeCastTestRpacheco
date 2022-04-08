//
//  Media.swift
//  chromeCastTestRpacheco
//
//  Created by Richard Pacheco on 4/5/22.
//

import Foundation
import AVFoundation

struct Media: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let thumbnailUrl: String
}

extension Media {
    var asPlayerItem: AVPlayerItem {
        AVPlayerItem(asset: AVURLAsset(url: URL(string: url)!))
    }
    
    static var playlist: [Media] = [
        .init(title: "Second video", url: Bundle.main.url(forResource: "video2", withExtension: "mp4")?.absoluteString ?? "", thumbnailUrl: ""),
        .init(title: "Third video", url: Bundle.main.url(forResource: "video3", withExtension: "mp4")?.absoluteString ?? "", thumbnailUrl: ""),
        .init(title: "Fourth video", url: Bundle.main.url(forResource: "video4", withExtension: "mp4")?.absoluteString ?? "", thumbnailUrl: "")

    ]
}
