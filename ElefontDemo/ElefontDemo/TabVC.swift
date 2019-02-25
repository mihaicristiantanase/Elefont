// ©2019 Mihai Cristian Tanase. All rights reserved.

import UIKit

class TabVC: UITabBarController {
  @IBAction func didPressLoadB() {
    if let vc = selectedViewController as? BaseVC {
      vc.loadFonts()
    }
  }

  @IBAction func didPressReleaseB() {
    if let vc = selectedViewController as? BaseVC {
      vc.releaseFonts()
    }
  }
}
