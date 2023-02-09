//
//  File.swift
//  
//
//  Created by Ivan Kh on 24.01.2023.
//

#if canImport(AppKit)
import AppKit
#endif

#if canImport(AppKit)
extension NSTextView {
    func edit(with style: RichTextNamedStyle.Proto) {
        guard let attributedString = attributedString().mutableCopy() as? NSMutableAttributedString else { return }

        let selectedRange = selectedRange
        var range: NSRange? = selectedRange
        let updates = style.apply(to: attributedString, range: &range)

        edit(with: updates)
    }

    public func edit(with updates: [NSAttributedString.Update]) {
        guard updates.count > 0 else { return }
        let selectedRange = selectedRange

        edit {
            apply(updates)
        }

        if let range = selectedRange.applied(updates) {
            setSelectedRange(range)
        }
    }

    public func edit(updates: () -> Void) {
        undoManager?.beginUndoGrouping()
        textStorage?.beginEditing()
        updates()
        didChangeText()
        textStorage?.endEditing()
        undoManager?.endUndoGrouping()
    }

    public func apply(_ updates: [NSAttributedString.Update]) {
        updates.forEach { apply($0) }
    }

    public func apply(_ update: NSAttributedString.Update) {
        var replacementRange: NSRange?
        var replacementString: String?
        var replacementAttributedString: NSAttributedString?
        var typingAttributes = typingAttributes

        switch update {
        case .replace(let range, let string):
            replacementRange = range
            replacementString = string

        case .replaceAttributed(let range, let string):
            replacementRange = range
            replacementAttributedString = string

        case .addAttributes(let range, let attributes):
            guard
                let mutableAttributedString = textStorage?.attributedString.mutableCopy() as? NSMutableAttributedString
            else { return }

            mutableAttributedString.addAttributes(attributes, range: range)
            replacementRange = range
            replacementAttributedString = mutableAttributedString.attributedSubstring(from: range)

            if selectedRange().length == 0 && range.upperBound == selectedRange().location {
                typingAttributes = attributes.merging(typingAttributes, uniquingKeysWith: { arg0, _ in arg0 })
            }

        case .removeAttributes(let range, let attributes):
            guard
                let mutableAttributedString = textStorage?.attributedString.mutableCopy() as? NSMutableAttributedString
            else { return }

            attributes.forEach { mutableAttributedString.removeAttribute($0, range: range) }
            replacementRange = range
            replacementAttributedString = mutableAttributedString.attributedSubstring(from: range)
        }

        if let replacementRange, let replacementAttributedString {
            if shouldChangeText(in: replacementRange, replacementString: replacementAttributedString.string) {
                textStorage?.replaceCharacters(in: replacementRange, with: replacementAttributedString)
            }
        }
        else if let replacementRange, let replacementString {
            if shouldChangeText(in: replacementRange, replacementString: replacementString) {
                textStorage?.replaceCharacters(in: replacementRange, with: replacementString)
            }
        }

        self.typingAttributes = typingAttributes
    }
}
#endif
