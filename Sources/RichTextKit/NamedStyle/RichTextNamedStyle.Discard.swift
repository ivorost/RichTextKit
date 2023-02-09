//
//  File.swift
//  
//
//  Created by Ivan Kh on 31.01.2023.
//

import Foundation

public extension RichTextNamedStyle {
    class Discard : RichTextNamedStyle.Proto {
        private let master: RichTextNamedStyle.Proto
        private let discard: RichTextNamedStyle.Proto

        public init(style discard: RichTextNamedStyle.Proto, for style: RichTextNamedStyle.Proto) {
            self.discard = discard
            self.master = style
        }

        public var name: String {
            master.name
        }

        public func matches(string: NSAttributedString, range: NSRange) -> Bool {
            master.matches(string: string, range: range)
        }

        public func apply(to string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            discard.remove(from: string, range: &range)
            + master.apply(to: string, range: &range)
        }

        public func remove(from string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            master.remove(from: string, range: &range)
        }
    }
}
