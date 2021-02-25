// Copyright © 2019 evaluni.com. All rights reserved.

import UIKit
import Castify
import Combine

class HomeViewController: UIViewController {
  
  @IBOutlet weak var liveListTable: UITableView!
  
  private let liveListRefresh = UIRefreshControl()
  
  private var scope = Set<AnyCancellable>()
  
  private var page = Page<Broadcast>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    liveListTable.separatorStyle = .none
    liveListTable.dataSource = self
    liveListTable.refreshControl = liveListRefresh

    liveListRefresh.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    refresh(liveListRefresh)
  }
  
  @objc private func refresh(_ sender: UIRefreshControl) {
    sender.beginRefreshing()
    castifyApi.listBroadcasts()
      .sink(receiveCompletion: { _ in sender.endRefreshing() }) { [weak self] page in
        self?.page = page
        self?.liveListTable.reloadData()
      }
      .store(in: &scope)
  }
}

extension HomeViewController {
  
  @IBAction
  func startBroadcasting() {
    guard let vc = UIStoryboard(name: "Broadcast", bundle: nil).instantiateInitialViewController() else {
      fatalError()
    }
    present(vc, animated: true)
  }
}

extension HomeViewController : UITableViewDataSource {
  
  func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
    return page.values.count
  }
  
  func tableView(_ table: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
    let cell = table.dequeueReusableCell(withIdentifier: "cell", for: path) as! LiveListCell
    cell.host = self
    cell.data = page.values[path.row]
    return cell
  }

}

class LiveListCell : UITableViewCell {
  
  var host: HomeViewController!
  
  @IBOutlet weak var panel: UIView!
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var preview: UIImageView!
  @IBOutlet weak var statusTip: UIView!
  @IBOutlet weak var statusTipLabel: UILabel!
  
  var data: Broadcast! = nil {
    didSet {
      preview.setImage(url: castifyApp.publicPreviewURL(ofBroadcastId: data.broadcastId))
      if data.stoppedAt == nil {
        statusTip.backgroundColor = .red
        statusTipLabel.text = "ON AIR"
      }
      else {
        statusTip.backgroundColor = .blue
        statusTipLabel.text = "ARCHIVE"
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    preview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap(_:))))
    preview.isUserInteractionEnabled = true
    
    // drop shadow
    panel.layer.masksToBounds = false
    panel.layer.shadowOffset  = CGSize(width: 0.5, height: 0.5)
    panel.layer.shadowColor   = UIColor.black.cgColor
    panel.layer.shadowOpacity = 0.5
  }

  @objc func onTap(_ _: UIGestureRecognizer) {
    guard let vc: PlayerViewController = UIStoryboard(name: "Player", bundle: nil).instantiateInitialViewController() else {
      fatalError()
    }
    vc.broadcast = data
    host.present(vc, animated: true)
  }
}
