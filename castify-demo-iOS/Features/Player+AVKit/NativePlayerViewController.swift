// Copyright © 2021 castify.jp. All rights reserved.

import UIKit
import AVKit

class NativePlayerViewController: UIViewController {

  var broadcast: Broadcast!
  
  @IBOutlet weak var playerView: PlayerView!

  @IBOutlet weak var status: UILabel!
  
  private var playerItem: AVPlayerItem?

  private var player: AVPlayer?
  
  deinit {
    playerItem?.removeObserver(self, forKeyPath: "status")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let href = "https://edge-api.castify.jp/streamers/\(broadcast.broadcastId)/index.m3u8?from=stable&player=avkit"
    
    playerItem = AVPlayerItem(url: URL(string: href)!)
    playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    
    player = AVPlayer(playerItem: playerItem)
    player?.play()
    
    playerView.layer.player = player
  }
  
  override func observeValue(forKeyPath _: String?, of _: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard let item = playerItem else {
      return
    }
    print("[player] status=\(item.status.rawValue)")
    if let error = item.error {
      print("[player] error=\(error)")
    }
  }
  
  @IBAction func close() {
    dismiss(animated: true)
  }
}

class PlayerView: UIView {

  override var layer: AVPlayerLayer {
    super.layer as! AVPlayerLayer
  }

  override static var layerClass: AnyClass { AVPlayerLayer.self }
}
