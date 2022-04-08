//
//  CastButton.swift
//  chromeCastTestRpacheco
//
//  Created by Richard Pacheco on 4/5/22.
//

import Foundation
import SwiftUI

struct CastButton: UIViewRepresentable {    
    func makeUIView(context: Context) -> CastButtonView {
        let castButton = CastButtonView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        return castButton
    }

    class Coordinator {
        var parentObserver: NSKeyValueObservation?
    }
    
    func updateUIView(_ uiView: CastButtonView, context: Context) { }

    func makeCoordinator() -> Self.Coordinator { Coordinator() }
}
