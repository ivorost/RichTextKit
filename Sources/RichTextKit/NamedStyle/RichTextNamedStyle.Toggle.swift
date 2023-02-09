//
//  File.swift
//  
//
//  Created by Ivan Kh on 01.02.2023.
//

import Foundation

public extension RichTextNamedStyle {
    class Toggle : RichTextNamedStyle.Proto {
        private let inner: RichTextNamedStyle.Proto

        public init(_ inner: RichTextNamedStyle.Proto) {
            self.inner = inner
        }

        public var name: String {
            inner.name
        }

        public func matches(string: NSAttributedString, range: NSRange) -> Bool {
            inner.matches(string: string, range: range)
        }

        public func apply(to string: NSMutableAttributedString,
                          range: inout NSRange?) -> [NSAttributedString.Update] {
            guard let theRange = range else { return [] }

            if matches(string: string, range: theRange) {
                return inner.remove(from: string, range: &range)
            }
            else {
                return inner.apply(to: string, range: &range)
            }
        }

        public func remove(from string: NSMutableAttributedString,
                           range: inout NSRange?) -> [NSAttributedString.Update] {
            return []
        }
    }
}

