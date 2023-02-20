//
//  RichTextMarkerStyle.swift
//  
//
//  Created by Ivan Kh on 19.01.2023.
//

import AppKit

/// List with plain text markers
public extension RichTextNamedStyle {
    class Marker : List {
        public let prefix: String

        public init(name: String, prefix: String, font: NSFont) {
            self.prefix = prefix
            super.init(name: name, kind: .bullet, font: font)
        }

        public override func listMarker(for attributedString: NSAttributedString, range: NSRange) -> String {
            prefix
        }
    }
}

public extension RichTextNamedStyle.Marker {
    class Copy : RichTextNamedStyle.Proxy {
        public override func apply(to string: NSMutableAttributedString,
                                   range: inout NSRange?) -> [NSAttributedString.Update] {
            guard let theRange = range else { return [] }
            let listMarker = ""
            let attachmentRange = NSMakeRange(theRange.location, 1)
            let paragraphStyle = NSMutableParagraphStyle()
            let list = NSTextList(markerFormat: .disc, options: 0)
            paragraphStyle.textLists = [list]

            return apply(updates: [
                .removeAttributes(range: attachmentRange, attributes: [.attachment]),
                .addAttributes(range: theRange, attributes: [.paragraphStyle: paragraphStyle]),
                .replace(range: attachmentRange, string: listMarker)],
                         to: string,
                         range: &range)
        }
    }
}
