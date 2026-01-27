import Cocoa

extension UserDefaults {
    func setColor(_ color: NSColor, forKey key: String) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
            set(data, forKey: key)
        }
    }

    func color(forKey key: String) -> NSColor? {
        guard let data = data(forKey: key),
              let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else {
            return nil
        }
        return color
    }
}
