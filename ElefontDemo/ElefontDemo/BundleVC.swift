// ©2019 Mihai Cristian Tanase. All rights reserved.

import Elefont
import UIKit

private var originalFontNames = [
  "OpenSans",
  "OpenSans-Bold",
  "OpenSans-BoldItalic",
  "OpenSans-Extrabold",
  "OpenSans-ExtraboldItalic",
  "OpenSans-Italic",
  "OpenSans-Light",
  "OpenSans-Semibold",
  "OpenSans-SemiboldItalic",
  "OpenSansLight-Italic",
]

final class BundleVC: BaseVC {
  private lazy var _fontNames = originalFontNames

  override var fontNames: [String] { return _fontNames }

  override func loadFonts() {
    Elefont.eat { fonts -> Void in
      print("Loaded Fonts", fonts)
      self._fontNames = fonts.sorted()
      self.tableView.reloadSections([0], with: .automatic)
    }
  }

  override func reloadOriginalFontNames() {
    _fontNames = originalFontNames
    tableView.reloadSections([0], with: .automatic)
  }
}
