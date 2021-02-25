// Copyright © 2019 evaluni.com. All rights reserved.

import UIKit

fileprivate let lastLoaderTask = CustomField<URLSessionDataTask>()

extension UIImageView {
  
  func setImage(url: URL) {
    let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, _ in
      if let image = data.flatMap(UIImage.init(data:)) {
        DispatchQueue.main.async { [weak self] in self?.image = image }
      }
    }
    lastLoaderTask[self]?.cancel()
    lastLoaderTask[self] = task
    task.resume()
  }
}
