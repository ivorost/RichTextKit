//
//  File.swift
//  
//
//  Created by Ivan Kh on 03.02.2023.
//

import Foundation


public extension RichTextNamedStyle {
    class Conditional : RichTextNamedStyle.Proto {
        private let condition: (NSAttributedString, NSRange) -> Bool
        private let style: RichTextNamedStyle.Proto

        public init(style: RichTextNamedStyle.Proto, condition: RichTextNamedStyle.Proto) {
            self.condition = { condition.matches(string: $0, range: $1) }
            self.style = style
        }

        public init(style: RichTextNamedStyle.Proto, condition: @escaping (NSAttributedString, NSRange) -> Bool) {
            self.condition = condition
            self.style = style
        }

        public var name: String {
            style.name
        }

        public func matches(string: NSAttributedString, range: NSRange) -> Bool {
            condition(string, range)
        }

        public func apply(to string: NSMutableAttributedString,
                          range: inout NSRange?) -> [NSAttributedString.Update] {
            if let theRange = range, matches(string: string, range: theRange) {
                return style.apply(to: string, range: &range)
            }
            else {
                return []
            }
        }

        public func remove(from string: NSMutableAttributedString,
                           range: inout NSRange?) -> [NSAttributedString.Update] {
            if let theRange = range, matches(string: string, range: theRange) {
                return style.remove(from: string, range: &range)
            }
            else {
                return []
            }
        }
    }
}
