import Foundation

final class ListSubcommand {
  func run() {
    do {
      let files = try FileManager.default.contentsOfDirectory(atPath: mslPath)
      for file in files {
        if file.contains(".bundle") {
          print(file.replacingOccurrences(of: ".bundle", with: "", options: NSString.CompareOptions.literal, range: nil))
        }
      }
    } catch {
      fatalError("Error reading \(mslPath) directory.")
    }
  }
}
