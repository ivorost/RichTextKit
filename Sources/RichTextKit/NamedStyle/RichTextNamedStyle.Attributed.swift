//
//  RichTextAttributedStyle.swift
//  
//
//  Created by Ivan Kh on 19.01.2023.
//

import AppKit

/// Not a strict (contains) match for attributes
public extension RichTextNamedStyle {
    class Attributed : RichTextNamedStyle.Proto {
        public enum Rule {
            case preserveFontTraits // apply only font family and size but preserve bold/italic traits
        }

        public let name: String
        private let attributes: [NSAttributedString.Key : Any]
        private let matchingAttributes: [NSAttributedString.Key : Any]
        private let rules: [Rule]

        public init(name: String,
                    attributes: [NSAttributedString.Key : Any],
                    matchingAttributes: [NSAttributedString.Key : Any]? = nil,
                    rules: [Rule] = []) {
            self.name = name
            self.attributes = attributes
            self.matchingAttributes = matchingAttributes ?? attributes
            self.rules = rules
        }

        public func matches(string attributedString: NSAttributedString, range: NSRange) -> Bool {
            guard attributedString.length > 0 else { return false }
            var longestEffectiveRange = NSRange()

            let fixedRange = range.location >= attributedString.length
            ? NSRange(location: max(0, range.location - 1), length: min(1, attributedString.length))
            : range

            for pair in matchingAttributes {
                let attribute = attributedString.attribute(pair.key,
                                                           at: fixedRange.location,
                                                           longestEffectiveRange: &longestEffectiveRange,
                                                           in: fixedRange)

                guard (attribute as? NSObject) == (pair.value as? NSObject) else { return false }
                guard longestEffectiveRange == range else { return false }
            }

            return true
        }

        public func apply(to attributedString: NSMutableAttributedString,
                          range: inout NSRange?) -> [NSAttributedString.Update] {
            if rules.contains(.preserveFontTraits) && attributes.contains(where: { $0.key == .font }) {
                return applyPreserving(to: attributedString, range: &range)
            }
            else {
                return applyExplicitly(to: attributedString, range: &range, attributes: attributes)
            }
        }

        public func applyExplicitly(to attributedString: NSMutableAttributedString,
                                    range: inout NSRange?,
                                    attributes: [NSAttributedString.Key : Any]) -> [NSAttributedString.Update] {
            guard let theRange = range else { return [] }

            return apply(updates: [.addAttributes(range: theRange, attributes: attributes)],
                         to: attributedString,
                         range: &range)
        }

        public func applyPreserving(to attributedString: NSMutableAttributedString,
                                    range: inout NSRange?) -> [NSAttributedString.Update] {
            guard let theRange = range else { return [] }
            guard let font = attributes.first(where: { $0.key == .font })?.value as? NSFont else { return [] }
            var updates = [NSAttributedString.Update]()
            let attributesWithoutFont = attributes.filter { $0.key != .font }

            attributedString.enumerateAttribute(.font, in: theRange) { value, range, _ in
                if let value = value as? NSFont {
                    let newDescriptor = font.fontDescriptor.withSymbolicTraits(value.fontDescriptor.symbolicTraits)
                    let newFont = NSFont(descriptor: newDescriptor, size: font.pointSize) ?? font
                    updates.append(.addAttributes(range: range, attributes: [.font: newFont]))
                }
                else {
                    updates.append(.addAttributes(range: range, attributes: [.font: font]))
                }
            }

            updates.append(
                contentsOf: applyExplicitly(to: attributedString, range: &range, attributes: attributesWithoutFont))

            return apply(updates: updates, to: attributedString, range: &range)
        }

        public func remove(from attributedString: NSMutableAttributedString,
                           range: inout NSRange?) -> [NSAttributedString.Update] {
            guard let theRange = range else { return [] }

            return apply(updates: [.removeAttributes(range: theRange, attributes: attributes.map { $0.key })],
                         to: attributedString,
                         range: &range)
        }
    }
}


public extension RichTextNamedStyle {
    class RemoveAttributes : RichTextNamedStyle.Proto {
        public var name: String
        private let attributes: [NSAttributedString.Key]

        public init(name: String, attributes: [NSAttributedString.Key]) {
            self.name = name
            self.attributes = attributes
        }

        public func matches(string: NSAttributedString, range: NSRange) -> Bool {
            false
        }

        public func apply(to string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            guard let theRange = range else { return [] }

            return apply(updates: [.removeAttributes(range: theRange, attributes: attributes)],
                         to: string,
                         range: &range)
        }

        public func remove(from string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            []
        }
    }
}


public extension RichTextNamedStyle {
    class CleanupAttributes : RichTextNamedStyle.Proto {
        public var name: String
        private let attributes: Set<NSAttributedString.Key>

        public init(name: String, except attributes: [NSAttributedString.Key]) {
            self.name = name
            self.attributes = .init(attributes)
        }

        public func matches(string: NSAttributedString, range: NSRange) -> Bool {
            false
        }

        public func apply(to string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            guard let theRange = range else { return [] }
            guard string.length > 0 else { return [] }
            guard string.length > 0 else { return [] }
            var effectiveRange = NSRange()
            var updates = [NSAttributedString.Update]()
            var index = 0

            repeat {
                let attributes = string
                    .attributes(at: index, effectiveRange: &effectiveRange)
                    .map { $0.key }
                    .filter { !self.attributes.contains($0) }

                if attributes.count > 0 {
                    updates.append(contentsOf: apply(
                        updates: [.removeAttributes(range: theRange, attributes: attributes)],
                        to: string,
                        range: &range))
                }

                index += effectiveRange.length
            }
            while effectiveRange.length > 0 && index < string.length

            return updates
        }

        public func remove(from string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            []
        }
    }
}


public extension RichTextNamedStyle.RemoveAttributes {
    static func text(name: String = "") -> RichTextNamedStyle.RemoveAttributes {
        RichTextNamedStyle.RemoveAttributes(name: name, attributes: [
            .font, .underlineStyle, .strikethroughStyle
        ])
    }
}
