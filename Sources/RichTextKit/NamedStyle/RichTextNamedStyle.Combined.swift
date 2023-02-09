//
//  File.swift
//  
//
//  Created by Ivan Kh on 31.01.2023.
//

import Foundation

public extension RichTextNamedStyle {
    class Combined : RichTextNamedStyle.Proto {
        private let primary: RichTextNamedStyle.Proto
        private let styles: [RichTextNamedStyle.Proto]

        public init(primary: RichTextNamedStyle.Proto, styles: [RichTextNamedStyle.Proto]) {
            self.primary = primary
            self.styles = styles
        }

        public init(primary: RichTextNamedStyle.Proto, style: RichTextNamedStyle.Proto) {
            self.primary = primary
            self.styles = [style]
        }

        public convenience init(_ styles: [RichTextNamedStyle.Proto]) {
            self.init(primary: styles.first ?? Stub.shared, styles: styles)
        }

        public var name: String {
            primary.name
        }

        public func matches(string: NSAttributedString, range: NSRange) -> Bool {
            primary.matches(string: string, range: range)
        }

        public func apply(to string: NSMutableAttributedString,
                          range: inout NSRange?) -> [NSAttributedString.Update] {
            styles.apply(to: string, range: &range)
        }

        public func remove(from string: NSMutableAttributedString,
                           range: inout NSRange?) -> [NSAttributedString.Update] {
            styles.remove(from: string, range: &range)
        }
    }
}
