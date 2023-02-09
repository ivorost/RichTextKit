//
//  File.swift
//  
//
//  Created by Ivan Kh on 01.02.2023.
//

import AppKit

protocol RichTextNamedStyleListCellProtocol {
    var textFont: NSFont { get set }
}

extension RichTextNamedStyle.List {
    typealias CellProtocol = RichTextNamedStyleListCellProtocol
}

extension RichTextNamedStyle.List {
    @objc(RichTextNamedStyleListCell)
    class Cell: RichTextNamedStyle.Cell, CellProtocol {
        let textTag: Int
        private(set) var text: String
        private(set) var textSize: CGSize = .zero
        private let minimumWidth: CGFloat = 25

        var textFont: NSFont {
            didSet {
                self.textSize = Cell.textSize(text: text, attributes: attributes)

            }
        }

        private var attributes: [NSAttributedString.Key: Any] {
            [.font: textFont]
        }

        init(text: String, font: NSFont, tag: Int) {
            self.text = text
            self.textTag = tag
            self.textFont = font
            super.init()
            self.font = font
            self.stringValue = text
            self.textSize = Cell.textSize(text: text, attributes: attributes)
        }

        required init(coder: NSCoder) {
            self.text = coder.decodeObject() as? String ?? ""
            self.textTag = coder.decodeObject() as? Int ?? 0
            self.textFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
            super.init(coder: coder)
            self.font = textFont
            self.stringValue = text
            self.textSize = Cell.textSize(text: text, attributes: attributes)
        }

        open func text(for attributedString: NSAttributedString, index: Int) -> String {
            text
        }

        open func updatedText(from: String, to: String, in string: NSAttributedString, at index: Int) {
            // for override
        }

        public func updateText(for string: NSAttributedString, index: Int) {
            let newText = text(for: string, index: index)
            guard newText != text else { return }
            let oldText = self.text

            self.text = newText
            self.textSize = Cell.textSize(text: text, attributes: attributes)
            self.updatedText(from: oldText, to: newText, in: string, at: index)
        }

        public override func encode(with coder: NSCoder) {
            coder.encode(text)
            coder.encode(textTag)
        }

        public override func cellSize() -> NSSize {
            return NSSize(width: max(minimumWidth, textSize.width), height: textSize.height)
        }

        public override func cellBaselineOffset() -> NSPoint {
            guard let font = font else { return .zero }
            let offsetY = font.descender.rounded(.down)
            return NSPoint(x: .zero, y: offsetY)
        }

        public override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
            super.draw(withFrame: cellFrame, in: controlView)
            drawText(in: cellFrame)
        }

        public override func draw(withFrame cellFrame: NSRect, in controlView: NSView?, characterIndex charIndex: Int) {
            super.draw(withFrame: cellFrame, in: controlView, characterIndex: charIndex)
            updateText(in: controlView, characterIndex: charIndex)
            drawText(in: cellFrame)
        }

        private func updateText(in controlView: NSView?, characterIndex charIndex: Int) {
            guard let attributedString = (controlView as? NSTextView)?.attributedString() else { return }
            updateText(for: attributedString, index: charIndex)
        }

        private func drawText(in frame: NSRect) {
            var textRect = frame
            textRect.origin.x += cellSize.width - textSize.width
            (text as NSString).draw(in: textRect, withAttributes: attributes)
        }

        private static func textSize(text: String, attributes: [NSAttributedString.Key: Any]) -> NSSize {
            let textSize    = (text as NSString).size(withAttributes: attributes)
            let width       = textSize.width.rounded(.up)
            let height      = textSize.height.rounded(.up)

            return NSSize(width: width, height: height)
        }
    }
}
