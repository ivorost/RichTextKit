//
//  File.swift
//  
//
//  Created by Ivan Kh on 01.02.2023.
//

import AppKit

/// Base class for list
extension RichTextNamedStyle {
    open class List : RichTextNamedStyle.Proto {
        public let name: String
        public let font: NSFont
        public let kind: Int

        public init(name: String, kind: Int, font: NSFont) {
            self.name = name
            self.kind = kind
            self.font = font
        }

        init(name: String, kind: Kind, font: NSFont) {
            self.name = name
            self.kind = kind.rawValue
            self.font = font
        }

        // MARK: - RichTextNamedStyle.Proto implementation

        public func matches(string attributedString: NSAttributedString, range: NSRange) -> Bool {
            guard let cell: Cell = attributedString.attachmentCell(at: range) else { return false }
            return cell.textTag == kind
        }

        public func apply(to attributedString: NSMutableAttributedString,
                          range: inout NSRange?) -> [NSAttributedString.Update] {
            guard let theRange = range else { return [] }

            guard !matches(string: attributedString, range: theRange) else {
                if var cell: CellProtocol = attributedString.attachmentCell(at: theRange) {
                    cell.textFont = font
                }
                return []
            }

            let listMarker = listMarkerAttributedString(for: attributedString, range: theRange)

            return apply(
                updates: [.replaceAttributed(range: NSRange(location: theRange.location, length: 0),
                                             string: listMarker)],
                to: attributedString,
                range: &range)
        }

        public func remove(from attributedString: NSMutableAttributedString,
                           range: inout NSRange?) -> [NSAttributedString.Update] {
            guard let theRange = range else { return [] }
            guard matches(string: attributedString, range: theRange) else { return [] }

            return apply(
                updates: [.replace(range: NSRange(location: theRange.location, length: 1), string: "")],
                to: attributedString,
                range: &range)
        }

        // MARK: - To override in concrete implementations

        open func listMarker(for attributedString: NSAttributedString,
                             range: NSRange) -> String {
            ""
        }

        open func listMarkerCell(for marker: String) -> NSTextAttachmentCell {
            Cell(text: marker, font: font, tag: kind)
        }

        // MARK: - Private members

        private func listMarkerAttributedString(for attributedString: NSAttributedString,
                                             range: NSRange) -> NSAttributedString {
            let attachment = NSTextAttachment()
            let listMarker = listMarker(for: attributedString, range: range)
            let attributedString = NSMutableAttributedString(attachment: attachment)

            attachment.attachmentCell = listMarkerCell(for: listMarker)
            attributedString.addAttribute(.font,
                                          value: font,
                                          range: NSRange(location: 0, length: attributedString.length))
            
            return attributedString
        }
    }
}


public extension RichTextNamedStyle.List {
    // !!! don't change Int value for this cases, they are stored in used data as identifier
    enum Kind : Int {
        case bullet = 1
        case number = 2
        case todo = 3
    }
}


public extension RichTextNamedStyle.List {
    typealias Agent = RichTextNamedStyleListWidthAgent
}


public protocol RichTextNamedStyleListWidthAgent : AnyObject {
    var calculatedWidth: CGFloat { get }
}
