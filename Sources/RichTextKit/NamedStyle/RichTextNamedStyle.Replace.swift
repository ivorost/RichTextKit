//
//  File.swift
//  
//
//  Created by Ivan Kh on 01.02.2023.
//

import Foundation

public extension RichTextNamedStyle {
    class Replace: Proto {
        private let src: Proto
        private let dst: Proto

        public init(src: Proto, dst: Proto) {
            self.src = src
            self.dst = dst
        }

        public var name: String {
            ""
        }

        public func matches(string: NSAttributedString, range: NSRange) -> Bool {
            false
        }

        public func apply(to string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            guard let theRange = range else { return [] }

            return src.matches(string: string, range: theRange)
            ? dst.apply(to: string, range: &range)
            : []
        }

        public func remove(from string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            []
        }
    }
}
