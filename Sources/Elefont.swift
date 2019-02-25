// ©2019 Mihai Cristian Tanase. All rights reserved.

import CoreGraphics
import CoreText
import UIKit

public final class Elefont {
  public static var debugEnabled = false

  public class func eat(
    atPath path: String?,
    completion: (([String]) -> Void)? = nil
  ) {
    guard let path = path else {
      completion?([])
      return
    }
    eat(at: URL(string: path), completion: completion)
  }

  public class func eat(
    bundle: Bundle = .main,
    completion: (([String]) -> Void)? = nil
  ) {
    eat(at: bundle.bundleURL, completion: completion)
  }

  public class func eat(
    at url: URL?,
    completion: (([String]) -> Void)? = nil
  ) {
    guard let url = url else {
      completion?([])
      return
    }
    var loadedFonts: [Font] = []
    loadedFonts += loadFonts(at: url)
    loadedFonts += loadFontsFromBundles(at: url)

    let alreadyLoaded = allLoadedFonts.map { $0.url }
    let justLoaded = loadedFonts.map { $0.url }
    for i in 0 ..< justLoaded.count {
      let justLoadedUrl = justLoaded[i]
      if alreadyLoaded.index(of: justLoadedUrl) == nil {
        allLoadedFonts.append(loadedFonts[i])
      }
    }

    completion?(loadedFonts.map { $0.name })
  }

  public class func release(_ name: String) -> Bool {
    let alreadyLoaded = allLoadedFonts.map { $0.name }
    guard let idx = alreadyLoaded.index(of: name),
      let ref = allLoadedFonts[idx].2 else {
      return false
    }
    var error: Unmanaged<CFError>?
    if CTFontManagerUnregisterGraphicsFont(ref, &error) {
      log("Successfully released font: '\(name)'.")
      return true
    } else {
      guard let error = error?.takeRetainedValue() else {
        log("Failed to release font '\(name)'.")
        return false
      }
      let errorDescription = CFErrorCopyDescription(error)
      log("Failed to release font '\(name)': \(String(describing: errorDescription))")
      return false
    }
  }

  public class func releaseEverything(completion: (([String]) -> Void)? = nil) {
    let bkp = allLoadedFonts
    var released: [String] = []
    for font in bkp {
      if release(font.name) {
        released.append(font.name)
      }
    }
    completion?(released)
  }
}

typealias FontPath = URL
typealias FontName = String
typealias FontExtension = String
typealias Font = (url: FontPath, name: FontName, ref: CGFont?)

var allLoadedFonts: [Font] = []

enum SupportedFontExtensions: String {
  case trueType = "ttf"
  case openType = "otf"

  init?(_ v: String?) {
    if SupportedFontExtensions.trueType.rawValue == v {
      self = .trueType
    } else if SupportedFontExtensions.openType.rawValue == v {
      self = .openType
    } else {
      return nil
    }
  }
}

extension Elefont {
  class func loadFonts(at url: URL) -> [Font] {
    var loadedFonts: [Font] = []
    do {
      let contents = try FileManager.default.contentsOfDirectory(
        at: url,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles]
      )

      let alreadyLoaded = allLoadedFonts.map { $0.url }
      for font in fonts(contents) {
        if let idx = alreadyLoaded.index(of: font.url) {
          loadedFonts.append(allLoadedFonts[idx])
        } else if let lf = loadFont(font) {
          loadedFonts.append(lf)
        }
      }
    } catch let error as NSError {
      log("""
      There was an error loading fonts.
      Path: \(url).
      Error: \(error)
      """)
    }
    return loadedFonts
  }

  class func loadFontsFromBundles(at url: URL) -> [Font] {
    var loadedFonts: [Font] = []
    do {
      let contents = try FileManager.default.contentsOfDirectory(
        at: url,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles]
      )
      for item in contents {
        guard item.absoluteString.contains(".bundle") else {
          continue
        }
        loadedFonts += loadFonts(at: item)
      }
    } catch let error as NSError {
      log("""
      There was an error accessing bundle with url.
      Path: \(url).
      Error: \(error)
      """)
    }
    return loadedFonts
  }

  class func loadFont(_ font: Font) -> Font? {
    let fileURL: FontPath = font.url
    let name = font.name
    var loadedFontName: String?
    var ref: CGFont?
    var error: Unmanaged<CFError>?
    if let data = try? Data(contentsOf: fileURL) as CFData,
      let dataProvider = CGDataProvider(data: data) {
      workaroundDeadlock()

      ref = CGFont(dataProvider)

      if CTFontManagerRegisterGraphicsFont(ref!, &error) {
        if let postScriptName = ref?.postScriptName {
          log("Successfully loaded font: '\(postScriptName)'.")
          loadedFontName = String(postScriptName)
        }
      } else if let error = error?.takeRetainedValue() {
        let errorDescription = CFErrorCopyDescription(error)
        log("Failed to load font '\(name)': \(String(describing: errorDescription))")
      }
    } else {
      guard let error = error?.takeRetainedValue() else {
        log("Failed to load font '\(name)'.")
        return nil
      }
      let errorDescription = CFErrorCopyDescription(error)
      log("Failed to load font '\(name)': \(String(describing: errorDescription))")
    }
    if let lfn = loadedFontName {
      return (fileURL, lfn, ref)
    }
    return nil
  }

  class func workaroundDeadlock() {
    _ = UIFont.systemFont(ofSize: 10)
  }
}

extension Elefont {
  class func fonts(_ contents: [URL]) -> [Font] {
    var fonts = [Font]()
    for fontUrl in contents {
      if let fontName = font(fontUrl) {
        fonts.append((fontUrl, fontName, nil))
      }
    }
    return fonts
  }

  class func font(_ fontUrl: URL) -> FontName? {
    let name = fontUrl.lastPathComponent
    let comps = name.components(separatedBy: ".")
    if comps.count < 2 { return nil }
    let fname = comps[0 ..< comps.count - 1].joined(separator: ".")
    return SupportedFontExtensions(comps.last!) != nil ? fname : nil
  }

  class func log(_ message: String) {
    if debugEnabled == true {
      print("[Elefont]: \(message)")
    }
  }
}
