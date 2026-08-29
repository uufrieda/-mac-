import AppKit

final class MenuIconView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.setFill()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 15, weight: .semibold),
            .foregroundColor: NSColor.black
        ]
        let text = NSAttributedString(string: "她", attributes: attributes)
        let size = text.size()
        text.draw(at: NSPoint(x: (bounds.width - size.width) / 2,
                              y: (bounds.height - size.height) / 2 - 1))
    }
}

func makeAppIcon(at output: URL) throws {
    let size = NSSize(width: 1024, height: 1024)
    let image = NSImage(size: size)
    image.lockFocus()

    let background = NSColor(calibratedRed: 0.97, green: 0.95, blue: 0.96, alpha: 1)
    background.setFill()
    NSBezierPath(roundedRect: NSRect(origin: .zero, size: size),
                 xRadius: 210, yRadius: 210).fill()

    let accent = NSColor(calibratedRed: 0.70, green: 0.31, blue: 0.48, alpha: 1)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont(name: "PingFangSC-Semibold", size: 590)
            ?? NSFont.systemFont(ofSize: 590, weight: .semibold),
        .foregroundColor: accent
    ]
    let text = NSAttributedString(string: "她", attributes: attributes)
    let textSize = text.size()
    text.draw(at: NSPoint(x: (size.width - textSize.width) / 2,
                          y: (size.height - textSize.height) / 2 - 35))

    image.unlockFocus()
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "SheFirstIcon", code: 1)
    }
    try png.write(to: output)
}

func makeMenuIcon(at output: URL) throws {
    let view = MenuIconView(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
    let pdf = view.dataWithPDF(inside: view.bounds)
    try pdf.write(to: output)
}

guard CommandLine.arguments.count == 3 else {
    fatalError("usage: make_icon <app-icon.png> <menu-icon.pdf>")
}

try makeAppIcon(at: URL(fileURLWithPath: CommandLine.arguments[1]))
try makeMenuIcon(at: URL(fileURLWithPath: CommandLine.arguments[2]))
