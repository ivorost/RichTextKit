//
//  File.swift
//  
//
//  Created by Ivan Kh on 31.01.2023.
//

import Foundation

public extension RichTextNamedStyle {
    class Array : RichTextNamedStyle.Proto {
        private let inner: [RichTextNamedStyle.Proto]

        public init(_ inner: [RichTextNamedStyle.Proto]) {
            self.inner = inner
        }

        public var name: String {
            ""
        }

        public func matches(string: NSAttributedString, range: NSRange) -> Bool {
            inner.matches(string: string, range: range)
        }

        public func apply(to string: NSMutableAttributedString,
                          range: inout NSRange?) -> [NSAttributedString.Update] {
            inner.apply(to: string, range: &range)
        }

        public func remove(from string: NSMutableAttributedString,
                           range: inout NSRange?) -> [NSAttributedString.Update] {
            inner.remove(from: string, range: &range)
        }
    }
}
