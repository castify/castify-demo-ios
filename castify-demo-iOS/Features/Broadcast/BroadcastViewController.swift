// Copyright © 2019 evaluni.com. All rights reserved.

import UIKit
import AVFoundation
import Castify

class BroadcastViewController: UIViewController {
  
  @IBOutlet weak var preview: Castify.PreviewView!
  @IBOutlet weak var publish: UIButton!
  @IBOutlet weak var toggleSilentButton: UIButton!
  @IBOutlet weak var toggleCameraButton: UIButton!
  @IBOutlet weak var status: UILabel!

  var broadcaster = Broadcaster(castifyApp)
  
  override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let session = AVAudioSession.sharedInstance()
    try? session.setCategory(.playAndRecord)
    try? session.setActive(true, options: [])

    broadcaster.delegate = self
    broadcaster.videoOutput.delegate = preview
    broadcaster.audioEncoderSetting = AACEncoderSetting()
    broadcaster.videoEncoderSetting = H264EncoderSetting(bps: 500_000, profile: .main)
    
    updateAudioInput()
    updateVideoInput()
    on(event: .connectivityUpdated(state: .closed(cause: nil)), from: broadcaster)
  }

  func connect() {
    if case .closed(_) = broadcaster.connectivity {
      broadcaster.resume()
    }
    else {
      broadcaster.pause()
    }
  }
  
  private func updateVideoInput() {
    var camera = Camera(position: toggleCameraButton.isSelected ? .back: .front)
    camera?.resolution = CGSize(width: 540, height: 960)
    camera?.rotation   = .portrait
    camera?.cropping   = false
    broadcaster.video = camera
  }
  
  private func updateAudioInput() {
    broadcaster.audio = toggleSilentButton.isSelected ? nil: Microphone()
  }
}

extension BroadcastViewController {
  
  @IBAction
  func resume() {
    if case .closed(_) = broadcaster.connectivity {
      broadcaster.resume()
    }
    else {
      broadcaster.pause()
    }
  }
  
  @IBAction
  func exit() {
    dismiss(animated: true)
  }
  
  @IBAction
  func toggleSilent() {
    toggleSilentButton.isSelected = !toggleSilentButton.isSelected
    updateAudioInput()
  }
  
  @IBAction
  func toggleCamera() {
    toggleCameraButton.isSelected = !toggleCameraButton.isSelected
    updateVideoInput()
  }
}

extension BroadcastViewController : BroadcasterDelegate {
  
  func on(event: BroadcasterEvent, from host: Broadcaster) {
    guard case .connectivityUpdated(let state) = event else {
      return
    }
    switch state {
    case .closed(let cause):
      if let error = cause {
        print("[error] \(error)")
      }
      status.text = "Inactive"
      status.backgroundColor = .darkGray

    case .opened:
      status.text = "On Air"
      status.backgroundColor = .red
    case .wip:
      status.text = "Preparing.."
      status.backgroundColor = .blue
    @unknown default:
      fatalError()
    }
    if case .closed(_) = state {
      publish.setTitle("Resume", for: .normal)
    }
    else {
      publish.setTitle("Pause", for: .normal)
    }
  }
}
