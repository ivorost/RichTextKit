//
//  RichTextNamedStyle.swift
//  
//
//  Created by Ivan Kh on 19.01.2023.
//

import Foundation


public struct RichTextNamedStyle {}


public protocol RichTextNamedStyleProtocol : AnyObject {
    var name: String { get }

    func matches(string: NSAttributedString, range: NSRange) -> Bool
    func apply(to string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update]
    func remove(from string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update]
}


public extension RichTextNamedStyle {
    typealias Proto = RichTextNamedStyleProtocol
}


public extension RichTextNamedStyle {
    final class Stub : Proto {
        public static let shared = Stub()
        private init() {}
        public var name: String { "" }
        public func matches(string: NSAttributedString, range: NSRange) -> Bool { false }
        public func apply(to string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] { [] }
        public func remove(from string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] { [] }
    }
}



extension RichTextNamedStyle.Proto {
    func apply(updates: [NSAttributedString.Update],
               to string: NSMutableAttributedString,
               range: inout NSRange?) -> [NSAttributedString.Update] {
        return string.apply(updates: updates, range: &range)
    }
}


extension Sequence where Element == any RichTextNamedStyle.Proto {
    func matching(string: NSAttributedString, range: NSRange) -> [RichTextNamedStyle.Proto] {
        filter { $0.matches(string: string, range: range) }
    }

    func matches(string: NSAttributedString, range: NSRange) -> Bool {
        reduce(true) { $0 && $1.matches(string: string, range: range) }
    }

    func apply(to string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
        reduce([NSAttributedString.Update]()) { $0 + $1.apply(to: string, range: &range) }
    }

    func remove(from string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
        reduce([NSAttributedString.Update]()) { $0 + $1.remove(from: string, range: &range) }
    }

    func firstNamedStyle(_ string: NSAttributedString, _ selection: NSRange) -> Element? {
        let paragraphsRanges = string.string.findRangesOfParagraphs(in: selection)

        return first { style in
            paragraphsRanges
                .map { style.matches(string: string, range: $0) }
                .reduce(true) { $0 && $1 }
        }
    }
}
