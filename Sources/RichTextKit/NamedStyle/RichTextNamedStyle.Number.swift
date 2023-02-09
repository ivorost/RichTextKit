//
//  RichTextNumberStyle.swift
//  
//
//  Created by Ivan Kh on 20.01.2023.
//

import AppKit


/// Numberred list
public extension RichTextNamedStyle {
    class Number : List {
        public let suffix: String
        private var defaultMarker: String { "1\(suffix)" }

        public init(name: String, suffix: String, font: NSFont) {
            self.suffix = suffix
            super.init(name: name, kind: .number, font: font.monospacedNumbers ?? font)
        }

        public override func listMarker(for attributedString: NSAttributedString, range: NSRange) -> String {
            let string = attributedString.string

            guard let previousParagraphRange = string.findRangeOfPreviousParagraph(from: range.location)
            else { return defaultMarker }

            guard let previousParagraphNumber = attributedString.listNumber(at: previousParagraphRange)
            else { return defaultMarker }

            return "\(previousParagraphNumber + 1)\(suffix)"
        }

        public override func listMarkerCell(for marker: String) -> NSTextAttachmentCell {
            Cell(text: marker, suffix: suffix, font: font, tag: kind)
        }
    }
}

private extension RichTextNamedStyle {
    class NumberMatch : Proto {
        let name: String = ""

        func matches(string: NSAttributedString, range: NSRange) -> Bool {
            let cell: Number.Cell? = string.attachmentCell(at: range)
            return cell != nil
        }

        func apply(to string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            []
        }

        func remove(from string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            []
        }
    }
}

extension RichTextNamedStyle.Number {
    class Cell : RichTextNamedStyle.List.Cell {
        private var suffix: String = ""

        init(text: String, suffix: String, font: NSFont, tag: Int) {
            self.suffix = suffix
            super.init(text: text, font: font, tag: tag)
        }

        required init(coder: NSCoder) {
            super.init(coder: coder)
            self.suffix = coder.decodeObject() as? String ?? ""
        }

        override func encode(with coder: NSCoder) {
            super.encode(with: coder)
            coder.encode(suffix)
        }

        public override func text(for attributedString: NSAttributedString, index: Int) -> String {
            guard let previousParagraphRange = attributedString.string.findRangeOfPreviousParagraph(from: index)
            else { return text }

            let previousParagraphListIndex = attributedString.listNumber(at: previousParagraphRange) ?? 0
            return "\(previousParagraphListIndex + 1)\(suffix)"
        }

        override func updatedText(from: String, to: String, in attributedString: NSAttributedString, at index: Int) {
            guard let nextParagraph = attributedString.string.findRangeOfNextParagraph(from: UInt(index))
            else { return }

            guard let cell: Self = attributedString.attachmentCell(at: nextParagraph)
            else { return }

            cell.updateText(for: attributedString, index: nextParagraph.location)
            cell.setNeedsDisplay(at: NSRange(location: index, length: 1))
        }
    }
}

private extension String {
    subscript(_ range: NSRange) -> String? {
        guard let stringRange = Range(range, in: self) else { return nil }
        return String(self[stringRange])
    }

    var listNumber: Int? {
        guard let numberString = components(separatedBy: CharacterSet.decimalDigits.inverted).first else { return nil }
        return Int(numberString)
    }
}

private extension NSFont {
    var monospacedNumbers: NSFont? {
        let features = [
            [NSFontDescriptor.FeatureKey.typeIdentifier: kNumberSpacingType,
             NSFontDescriptor.FeatureKey.selectorIdentifier: kMonospacedNumbersSelector],
        ]

        let fontDescriptor = fontDescriptor.addingAttributes(
            [NSFontDescriptor.AttributeName.featureSettings: features]
        )

        return NSFont(descriptor: fontDescriptor, size: self.pointSize)
    }
}

private extension NSAttributedString {
    func listNumber(at range: NSRange) -> Int? {
        guard let cell: RichTextNamedStyle.Number.Cell = attachmentCell(at: range)
        else { return nil }

        guard cell.textTag == RichTextNamedStyle.List.Kind.number.rawValue
        else { return nil }

        return cell.text.listNumber
    }

    func set(listNumber: Int, at range: NSRange) -> Int? {
        guard let cell: RichTextNamedStyle.Number.Cell = attachmentCell(at: range)
        else { return nil }

        guard cell.textTag == RichTextNamedStyle.List.Kind.number.rawValue
        else { return nil }

        return cell.text.listNumber
    }
}
