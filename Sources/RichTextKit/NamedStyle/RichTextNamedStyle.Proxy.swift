//
//  File.swift
//  
//
//  Created by Ivan Kh on 31.01.2023.
//

import Foundation


extension RichTextNamedStyle {
    open class Proxy : Proto {
        public var inner: Proto

        public init(_ inner: Proto = Stub.shared) {
            self.inner = inner
        }

        public var name: String {
            inner.name
        }

        public func matches(string: NSAttributedString, range: NSRange) -> Bool {
            inner.matches(string: string, range: range)
        }

        public func apply(to string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            inner.apply(to: string, range: &range)
        }

        public func remove(from string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            inner.remove(from: string, range: &range)
        }
    }
}
