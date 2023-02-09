//
//  File.swift
//  
//
//  Created by Ivan Kh on 01.02.2023.
//

import AppKit


/// Toggle paragraph prefix
public extension RichTextNamedStyle {
    class Todo : List {
        public init(name: String, font: NSFont) {
            super.init(name: name, kind: .todo, font: font)
        }

        public override func matches(string attributedString: NSAttributedString, range: NSRange) -> Bool {
            let cell: Cell? = attributedString.attachmentCell(at: range)
            return cell != nil
        }

        public override func listMarkerCell(for marker: String) -> NSTextAttachmentCell {
            Cell(font: font)
        }
    }
}


extension RichTextNamedStyle.Todo {
    @objc(RichTextNamedStyleTodoCell)
    class Cell: RichTextNamedStyle.Cell, NSTextAttachmentClickableCell, CellProtocol {
        var textFont: NSFont
        var checked: Bool = false

        init(font: NSFont) {
            self.textFont = font
            super.init()
        }

        required init(coder: NSCoder) {
            self.textFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
            self.checked = coder.decodeObject() as? Bool ?? false
            super.init(coder: coder)
        }

        public override func encode(with coder: NSCoder) {
            coder.encode(checked)
        }

        public override func cellSize() -> NSSize {
            let coef = (textFont.ascender - textFont.descender) / Cell.imageRegular.size.height
            return NSSize(width: max(Cell.minimumWidth,
                                     (Cell.imageRegular.size.width * coef).rounded(.up) + Cell.paddingRight),
                          height: (Cell.imageRegular.size.height * coef).rounded(.up))
        }

        public override func cellBaselineOffset() -> NSPoint {
            let offsetY = textFont.descender.rounded(.down)
            return NSPoint(x: .zero, y: offsetY)
        }

        override func draw(withFrame cellFrame: NSRect, in controlView: NSView?, characterIndex charIndex: Int) {
            guard let image = currentImage else { return }
            var rect = cellFrame
            let coef = min(rect.size.width / image.size.width, rect.size.height / image.size.height)

            super.draw(withFrame: cellFrame, in: controlView, characterIndex: charIndex)

            rect.size.width = image.size.width * coef
            rect.size.height = image.size.height * coef
            currentImage?.draw(in: rect)
        }

        func clicked(textView: NSTextView, in cellFrame: NSRect, at charIndex: Int) {
            checked = !checked
            textView.layoutManager?.invalidateDisplay(forCharacterRange: NSRange(location: charIndex, length: 1))
            textView.delegate?.textDidChange?(Notification(name: NSText.didChangeNotification))
        }

        private var currentImage: NSImage? {
            checked ? Cell.imageChecked : Cell.imageRegular
        }
    }
}


private extension RichTextNamedStyle.Todo.Cell {
    private static let color = NSColor(named: "notes_todo") ?? .black
    private static let imageRegular = NSImage(systemSymbolName: "circle",
                                              accessibilityDescription: "nil")?.tint(color) ?? NSImage()
    private static let imageChecked = NSImage(systemSymbolName: "checkmark.circle",
                                              accessibilityDescription: nil)?.tint(color) ?? NSImage()
    private static let paddingRight: CGFloat = 4
    private static let minimumWidth: CGFloat = 25
}


private extension NSImage {
    func tint(_ color: NSColor) -> NSImage {
        return NSImage(size: size, flipped: false) { (rect) -> Bool in
            color.set()
            rect.fill()
            self.draw(in: rect, from: NSRect(origin: .zero, size: self.size), operation: .destinationIn, fraction: 1.0)
            return true
        }
    }
}
