// ©2019 Mihai Cristian Tanase. All rights reserved.

import UIKit

class TabVC: UITabBarController {
  @IBAction func didPressLoadB() {
    if let vc = selectedViewController as? BaseVC {
      vc.loadFonts()
      listFonts()
    }
  }

  @IBAction func didPressReleaseB() {
    if let vc = selectedViewController as? BaseVC {
      vc.releaseFonts()
      listFonts()
    }
  }
}

func listFonts() {
  for name in UIFont.familyNames {
    let names = UIFont.fontNames(forFamilyName: name)
    print("Font \(name): \(names.joined(separator: " "))")
  }
}
