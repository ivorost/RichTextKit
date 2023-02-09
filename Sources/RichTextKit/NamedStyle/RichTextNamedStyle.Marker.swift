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
