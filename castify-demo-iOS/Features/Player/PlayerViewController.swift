// Copyright © 2019 evaluni.com. All rights reserved.

import AVFoundation
import UIKit
import Castify

class PlayerViewController: UIViewController {

  var broadcast: Broadcast!
  
  @IBOutlet weak var preview: Castify.PreviewView!
  @IBOutlet weak var status: UILabel!
  @IBOutlet weak var slider: UISlider!
  @IBOutlet weak var timeIndicator: UILabel!

  var player = Player(castifyApp)
  var duration: TimeInterval = 0
  var playhead: TimeInterval = 0
  var info: SourceInfo!
  
  var isSliderDragged = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    slider.addTarget(self, action: #selector(seek(_: event:)), for: .valueChanged)
    
    let session = AVAudioSession.sharedInstance()
    try? session.setCategory(.playback)
    try? session.setActive(true, options: [])
    
    player.videoOutput.delegate = preview
    player.delegate = self
    player.source = Source(castifyApp, broadcast: broadcast.broadcastId)
    player.source?.load() { [weak self] res in
      guard case .success(let info) = res else {
        return
      }
      DispatchQueue.main.async { self?.on(metadata: info) }
    }
  }
  
  private func on(metadata info: SourceInfo) {
    self.info = info
    if info.stoppedAt == nil {
      slider.maximumValue = 1
      slider.value = 1
      slider.isEnabled = false
      player.seek() // live
    }
    else {
      duration = Double(info.stoppedAt! - info.startedAt) / 1000.0
      slider.maximumValue = Float(duration)
      slider.value = 0
      slider.isEnabled = true
      player.seek(to: 0)
    }
    updateTimeIndicator()
  }
  
  private func updateTimeIndicator() {
    timeIndicator.text = toDurationString(playhead) + " / " + toDurationString(duration)
  }
}

fileprivate func toDurationString(_ src: TimeInterval) -> String {
  let s = Int(src)
  return String(
    format: "%02d:%02d:%02d",
    s / 60 / 60,
    s / 60 % 60,
    s % 60
  )
}

extension PlayerViewController {
  
  @IBAction func exit() {
    dismiss(animated: true)
  }
  
  @IBAction func seek(_ host: UISlider, event: UIEvent) {
    playhead = TimeInterval(host.value)
    updateTimeIndicator()
    if event.allTouches?.first?.phase != .ended {
      isSliderDragged = true
    }
    else {
      isSliderDragged = false
      player.seek(to: playhead)
    }
  }

  @IBAction func togglePaused(sender: UIButton) {
    let paused = !sender.isSelected
    sender.isSelected = paused
    player.paused     = paused
  }
  
  @IBAction func toggleAudio(sender: UIButton) {
    let disabled = !sender.isSelected
    sender.isSelected     =  disabled
    player.isAudioEnabled = !disabled
  }
  
  @IBAction func toggleVideo(sender: UIButton) {
    let disabled = !sender.isSelected
    sender.isSelected     =  disabled
    player.isVideoEnabled = !disabled
  }
}

extension PlayerViewController : PlayerDelegate {
  func on(event: PlayerEvent, from host: Player) {
    
    switch event {
    case .timer(let time) where !isSliderDragged:
      playhead = time
      updateTimeIndicator()
      
    case .connectivityUpdated(.closed(let cause)):
      if let error = cause {
        print("[error] \(error)")
      }
      status.text = "Inactive"
      status.backgroundColor = .darkGray
      
    case .connectivityUpdated(.opened):
      status.text = "Played"
      status.backgroundColor = .red
      
    case .connectivityUpdated(.wip):
      status.text = "Preparing.."
      status.backgroundColor = .blue

    default:
      ()
    }
    
    guard case .connectivityUpdated(let state) = event else {
      return
    }
    print("state=\(state)")
  }
}

extension PlayerViewController {
  override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
}
