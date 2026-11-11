import AppKit

/// Drawing for app icons: a near-black squircle with the app's mark on top.
/// Each app supplies its own `mark`, which draws into the squircle's rect.
public enum SquircleIcon {
    /// Draws the squircle (inset slightly, like macOS app icons) into the
    /// current graphics context, then the mark.
    public static func draw(side: CGFloat, mark: (NSRect) -> Void) {
        let inset = side * 0.055
        let rect = NSRect(x: inset, y: inset, width: side - 2 * inset, height: side - 2 * inset)
        NSColor(Theme.squircleBG).setFill()
        NSBezierPath(roundedRect: rect, xRadius: rect.width * 0.23, yRadius: rect.width * 0.23).fill()
        mark(rect)
    }

    /// The icon as an image, e.g. for `NSApp.applicationIconImage`.
    public static func image(side: CGFloat = 512, mark: (NSRect) -> Void) -> NSImage {
        let img = NSImage(size: NSSize(width: side, height: side))
        img.lockFocus()
        draw(side: side, mark: mark)
        img.unlockFocus()
        return img
    }

    /// Writes every size macOS needs into a `.iconset` folder; `iconutil -c icns`
    /// turns that folder into AppIcon.icns.
    public static func writeIconset(to dir: URL, mark: (NSRect) -> Void) throws {
        let sizes: [(String, Int)] = [
            ("icon_16x16", 16), ("icon_16x16@2x", 32),
            ("icon_32x32", 32), ("icon_32x32@2x", 64),
            ("icon_128x128", 128), ("icon_128x128@2x", 256),
            ("icon_256x256", 256), ("icon_256x256@2x", 512),
            ("icon_512x512", 512), ("icon_512x512@2x", 1024),
        ]
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        for (name, px) in sizes {
            let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
                                       bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                       colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
            draw(side: CGFloat(px), mark: mark)
            NSGraphicsContext.restoreGraphicsState()
            guard let data = rep.representation(using: .png, properties: [:]) else { continue }
            try data.write(to: dir.appendingPathComponent("\(name).png"))
        }
    }

    /// If the app was launched with `--write-iconset <folder>`, writes the
    /// iconset there and quits. The shared build script uses this to make
    /// AppIcon.icns. Call it first thing at launch.
    public static func writeIconsetIfRequested(mark: (NSRect) -> Void) {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "--write-iconset"), args.count > i + 1 else { return }
        do {
            try writeIconset(to: URL(fileURLWithPath: args[i + 1], isDirectory: true), mark: mark)
            exit(0)
        } catch {
            FileHandle.standardError.write(Data("could not write iconset: \(error)\n".utf8))
            exit(1)
        }
    }

    /// A black-on-clear template image for the menu bar; macOS tints it to
    /// match the menu bar.
    public static func template(size: NSSize, draw: (NSRect) -> Void) -> NSImage {
        let img = NSImage(size: size)
        img.lockFocus()
        draw(NSRect(origin: .zero, size: size))
        img.unlockFocus()
        img.isTemplate = true
        return img
    }
}
