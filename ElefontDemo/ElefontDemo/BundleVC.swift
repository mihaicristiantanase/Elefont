// ©2019 Mihai Cristian Tanase. All rights reserved.

import Elefont
import UIKit

private var originalFontNames = [
  "Open Sans",
  "Open Sans Bold",
  "Open Sans Bold Italic",
  "Open Sans Extra Bold",
  "Open Sans Extra Bold Italic",
  "Open Sans Italic",
  "Open Sans Light",
  "Open Sans Semi Bold",
  "Open Sans Semi Bold Italic",
  "Open SansLight Italic",
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
