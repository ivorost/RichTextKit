//
//  File.swift
//  
//
//  Created by Ivan Kh on 25.01.2023.
//

import Foundation


/// Applies style to paragraphs that interects the range
public extension RichTextNamedStyle {
    class Ranges {
        private let inner: RichTextNamedStyle.Proto

        public init(_ inner: RichTextNamedStyle.Proto) {
            self.inner = inner
        }

        func ranges(for string: String, range: NSRange) -> [NSRange] {
            []
        }
    }
}


extension RichTextNamedStyle.Ranges : RichTextNamedStyle.Proto {
    public var name: String {
        return inner.name
    }

    public func matches(string attributedString: NSAttributedString, range: NSRange) -> Bool {
        let ranges = ranges(for: attributedString.string, range: range)

        for range in ranges {
            if !inner.matches(string: attributedString, range: range) {
                return false
            }
        }

        return true
    }

    public func apply(to attributedString: NSMutableAttributedString,
                      range: inout NSRange?) -> [NSAttributedString.Update] {
        exec(for: attributedString, range: &range, block: inner.apply)
    }

    public func remove(from attributedString: NSMutableAttributedString,
                       range: inout NSRange?) -> [NSAttributedString.Update] {
        exec(for: attributedString, range: &range, block: inner.remove)
    }

    private func exec(for attributedString: NSMutableAttributedString,
                      range: inout NSRange?,
                      block: (NSMutableAttributedString, inout NSRange?) -> [NSAttributedString.Update])
    -> [NSAttributedString.Update] {

        guard let theRange = range else { return [] }
        let ranges = ranges(for: attributedString.string, range: theRange)
        var updates = [NSAttributedString.Update]()

        for var paragraphRange: NSRange? in ranges {
            paragraphRange = paragraphRange?.applied(updates)
            updates.append(contentsOf: block(attributedString, &paragraphRange))
        }

        range = range?.applied(updates)

        return updates
    }
}


public extension RichTextNamedStyle {
    class Paragraphs : Ranges {
        public enum Trait {
            case withoutLinebreaks
            case withPrecedingLineBreak
        }

        let trait: Trait

        public convenience override init(_ inner: Proto) {
            self.init(inner: inner)
        }

        public init(inner: Proto, trait: Trait = .withoutLinebreaks) {
            self.trait = trait
            super.init(inner)
        }

        override func ranges(for string: String, range: NSRange) -> [NSRange] {
            var result = string.findRangesOfParagraphs(in: range)

            switch trait {
            case .withPrecedingLineBreak:
                result = result.map { range in
                    range.location > 0
                    ? NSRange(location: range.location - 1, length: range.length + 1)
                    : range
                }
            default:
                break
            }

            return result
        }
    }
}


public extension RichTextNamedStyle {
    class PreviousParagraph : Ranges {
        override func ranges(for string: String, range: NSRange) -> [NSRange] {
            guard let range = string.findRangeOfPreviousParagraph(from: range.location) else { return [] }
            return [range]
        }
    }
}
