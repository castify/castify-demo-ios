// Copyright © 2019 castify.jp. All rights reserved.

import UIKit
import Castify

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ app: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    CastifyApp.loggingOption = LoggingOption(level: .debug)
    return true
  }
}

let castifyApp = CastifyApp(token: <# Castify API Token #>)
