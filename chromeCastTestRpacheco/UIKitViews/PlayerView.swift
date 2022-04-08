//
//  PlayerView.swift
//  chromeCastTestRpacheco
//
//  Created by Richard Pacheco on 4/5/22.
//

import AVFoundation
import UIKit
import GoogleCast

enum PlaybackState {
    case created
    case createdCast
    case playCast
    case play
    case pauseCast
    case pause
    case finishedCast
    case finished
}

final class PlayerView: UIView {
    private var playbackState: PlaybackState = .created
    private let timeObserver = "currentItem.loadedTimeRanges"
    //timers
    private var localTimer: Timer?
    private var castTimer: Timer?

    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    var player: AVPlayer? {
        get {
            playerLayer.player
        }
        set {
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.player = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        listenForCastConnection()
        
        if CastManager.shared.hasConnectionEstablished {
            playbackState = .createdCast
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        player?.removeObserver(self, forKeyPath: timeObserver)
    }
    
    func initPlayerLayer() {
        guard let item = currentItem, let url = URL(string: item.url) else { return }
        
        player = AVPlayer(url: url)
        player?.addObserver(self, forKeyPath: timeObserver, options: .new, context: nil)
//        playerLayer = AVPlayerLayer(player: player)
        layer.addSublayer(playerLayer)
        playerLayer.frame = bounds
//        createSpinner()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayer && keyPath == timeObserver {
            let loadedTimeRanges = player?.currentItem?.loadedTimeRanges
            guard let timeRanges = loadedTimeRanges, timeRanges.count > 0, let timeRange = timeRanges[0] as? CMTimeRange else { return }
            let currentBufferDuration = CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))
            if player?.status == AVPlayer.Status.readyToPlay && currentBufferDuration > 2 {
//                if playPauseButton == nil {
//                    createPlayPauseButton()
//                }
//                if buttonStackView == nil {
//                    createButtonStackView()
//                }
//                spinner.stopAnimating()
            }
        }
    }
    
    // MARK: - Add Cast Connection Listener
    
    private func listenForCastConnection() {
        let sessionStatusListener: (CastSessionStatus) -> Void = { status in
            switch status {
            case .started:
                self.startCastPlay()
            case .resumed:
                self.continueCastPlay()
            case .ended, .failedToStart:
                if self.playbackState == .playCast {
                    self.playbackState = .pause
                    self.startPlayer(nil)
                } else if self.playbackState == .pauseCast {
                    self.playbackState = .play
                    self.pausePlayer(nil)
                }
            default: break
            }
        }
        
        CastManager.shared.addSessionStatusListener(listener: sessionStatusListener)

    }
    
    private func startCastPlay() {
        guard let currentPlayerItem = player?.currentItem, let currentTime = player?.currentTime().seconds, let item = currentItem else { return }
        
        let duration = currentPlayerItem.asset.duration.seconds
        playbackState = .playCast
        player?.pause()
        let castMediaInfo = CastManager.shared.buildMediaInformation(with: item.title, with: item.title, with: "Nodes", with: duration, with: item.url, with: GCKMediaStreamType.buffered, with: item.thumbnailUrl)
        
        CastManager.shared.startSelectedItemRemotely(castMediaInfo, at: currentTime, completion: { done in
            if !done {
                self.playbackState = .pause
                self.startPlayer(nil)
            } else {
                self.scheduleCastTimer()
            }
        })
    }
    
    private func continueCastPlay() {
        playbackState = .playCast
        CastManager.shared.playSelectedItemRemotely(to: nil) { (done) in
            if !done {
                self.playbackState = .pause
                self.startPlayer(nil)
            }
        }
    }
    
    private func pauseCastPlay() {
        playbackState = .pauseCast
        CastManager.shared.pauseSelectedItemRemotely(to: nil) { (done) in
            if !done {
                self.playbackState = .pause
                self.startPlayer(nil)
            }
        }
    }
    
    @objc private func startPlayer(_ sender: Any?) {
        if playbackState == .pause || playbackState == .created {
            scheduleLocalTimer()
            player?.play()
            playbackState = .play
        } else if playbackState == .createdCast {
            scheduleCastTimer()
            startCastPlay()
        } else {
            scheduleCastTimer()
            player?.pause()
            playbackState = .playCast
            continueCastPlay()
        }
        
//        changeToPauseButton()
    }

    // MARK: Pause Player
    
    @objc private func pausePlayer(_ sender: Any?) {
        if playbackState == .play {
            player?.pause()
            playbackState = .pause
        } else {
            player?.pause()
            playbackState = .pauseCast
            pauseCastPlay()
        }
        
//        changeToPlayButton()
    }
    
    // MARK: - Update slider on Local
    
    private func scheduleLocalTimer() {
        DispatchQueue.main.async {
            switch self.playbackState {
            case .play, .pause, .created:
                self.castTimer?.invalidate()
                self.castTimer = nil
                self.localTimer?.invalidate()
                self.localTimer = Timer.scheduledTimer(timeInterval: 1,
                                                          target: self,
                                                          selector: #selector(self.updateInfoContent),
                                                          userInfo: nil,
                                                          repeats: true)
            default:
                self.localTimer?.invalidate()
                self.localTimer = nil
            }
        }
    }
    
    @objc private func updateInfoContent() {
        guard let currentItem = player?.currentItem else { return }
        let currentTime = player?.currentTime().seconds
        let duration = currentItem.asset.duration.seconds
//        slider.value = Float(currentTime / duration)
        
//        totalTimeLabel.text = duration.toTimeString() as String
//        currentTimeLabel.text = currentTime.toTimeString() as String
        
    }
    
    private func scheduleCastTimer() {
        DispatchQueue.main.async {
            switch self.playbackState {
            case .playCast, .pauseCast, .createdCast:
                self.localTimer?.invalidate()
                self.localTimer = nil
                self.castTimer?.invalidate()
                self.castTimer = Timer.scheduledTimer(timeInterval: 0.5,
                                                      target: self,
                                                      selector: #selector(self.sendCurrentTimeCastSessionRequest),
                                                      userInfo: nil,
                                                      repeats: true)
            default:
                self.castTimer?.invalidate()
                self.castTimer = nil
            }
        }
    }
    
    @objc private func sendCurrentTimeCastSessionRequest() {
        CastManager.shared.getSessionCurrentTime { (time) in
            guard let time = time,
                  let currentItem = player?.currentItem else { return }
            let duration = currentItem.asset.duration.seconds
//            self.slider.value = Float(time / duration)
            
//            self.totalTimeLabel.text = duration.toTimeString() as String
//            self.currentTimeLabel.text = time.toTimeString() as String
        }
    }
    
}

final class CastButtonView: GCKUICastButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let castButton = GCKUICastButton(frame: frame)
        castButton.tintColor = UIColor.gray
        self.addSubview(castButton)
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
