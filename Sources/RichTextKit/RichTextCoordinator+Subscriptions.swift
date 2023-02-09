//
//  RichTextCoordinator+Subscriptions.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-05-22.
//  Copyright © 2022 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(tvOS)
import SwiftUI

extension RichTextCoordinator {

    /**
     Make the coordinator subscribe to context changes.
     */
    func subscribeToContextChanges() {
        subscribeToContent()
        subscribeToAlignment()
        subscribeToBackgroundColor()
        subscribeToFontName()
        subscribeToFontSize()
        subscribeToForegroundColor()
        subscribeToHighlightedRange()
        subscribeToHighlightingStyle()
        subscribeToIsBold()
        subscribeToIsEditingText()
        subscribeToIsItalic()
        subscribeToIsStrikethrough()
        subscribeToIsUnderlined()
        subscribeToSelectedRange()
        subscribeToShouldCopySelection()
        subscribeToShouldPasteImage()
        subscribeToShouldPasteImages()
        subscribeToShouldPasteText()
        subscribeToShouldRedoLatestChange()
        subscribeToShouldUndoLatestChange()
        subscribeToNamedStyle()
    }
}

private extension RichTextCoordinator {

    func subscribeToContent() {
        richTextContext.$content
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setContent($0) })
            .store(in: &cancellables)
    }

    func subscribeToAlignment() {
        richTextContext.$textAlignment
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setAlignment(to: $0) })
            .store(in: &cancellables)
    }

    func subscribeToBackgroundColor() {
        richTextContext.$backgroundColor
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setBackgroundColor(to: $0) })
            .store(in: &cancellables)
    }

    func subscribeToFontName() {
        richTextContext.$fontName
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setFontName(to: $0) })
            .store(in: &cancellables)
    }

    func subscribeToFontSize() {
        richTextContext.$fontSize
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setFontSize(to: $0) })
            .store(in: &cancellables)
    }

    func subscribeToForegroundColor() {
        richTextContext.$foregroundColor
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setForegroundColor(to: $0) })
            .store(in: &cancellables)
    }

    func subscribeToHighlightedRange() {
        richTextContext.$highlightedRange
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setHighlightedRange(to: $0) })
            .store(in: &cancellables)
    }

    func subscribeToHighlightingStyle() {
        richTextContext.$highlightingStyle
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setHighlightingStyle(to: $0) })
            .store(in: &cancellables)
    }

    func subscribeToIsBold() {
        richTextContext.$isBold
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setStyle(.bold, to: $0) })
            .store(in: &cancellables)
    }

    func subscribeToIsEditingText() {
        richTextContext.$isEditingText
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setIsEditing(to: $0) })
            .store(in: &cancellables)
    }

    func subscribeToIsItalic() {
        richTextContext.$isItalic
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setStyle(.italic, to: $0) })
            .store(in: &cancellables)
    }

    func subscribeToIsStrikethrough() {
        richTextContext.$isStrikethrough
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setStyle(.strikethrough, to: $0) })
            .store(in: &cancellables)
    }

    func subscribeToIsUnderlined() {
        richTextContext.$isUnderlined
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setStyle(.underlined, to: $0) })
            .store(in: &cancellables)
    }

    func subscribeToSelectedRange() {
        richTextContext.$selectedRangeChange
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setSelectedRange(to: $0) })
            .store(in: &cancellables)
    }

    func subscribeToShouldCopySelection() {
        richTextContext.$shouldCopySelection
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.copySelection($0) })
            .store(in: &cancellables)
    }

    func subscribeToShouldPasteImage() {
        richTextContext.$shouldPasteImage
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.pasteImage($0) })
            .store(in: &cancellables)
    }

    func subscribeToShouldPasteImages() {
        richTextContext.$shouldPasteImages
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.pasteImages($0) })
            .store(in: &cancellables)
    }

    func subscribeToShouldPasteText() {
        richTextContext.$shouldPasteText
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.pasteText($0) })
            .store(in: &cancellables)
    }

    func subscribeToShouldRedoLatestChange() {
        richTextContext.$shouldRedoLatestChange
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.redoLatestChange($0) })
            .store(in: &cancellables)
    }

    func subscribeToShouldUndoLatestChange() {
        richTextContext.$shouldUndoLatestChange
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.undoLatestChange($0) })
            .store(in: &cancellables)
    }

    func subscribeToNamedStyle() {
        richTextContext.$namedStyle
            .filter { [weak self] _ in return self?.syncingContext != true }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] in self?.setStyle($0) })
            .store(in: &cancellables)
    }
}

internal extension RichTextCoordinator {

    func setContent(_ content: NSAttributedString) {
        textView.setRichText(content)
    }

    func copySelection(_ shouldCopy: Bool) {
        guard shouldCopy else { return }
        textView.copySelection()
    }

    func pasteImage(_ data: (image: ImageRepresentable, atIndex: Int, moveCursor: Bool)?) {
        guard let data = data else { return }
        textView.pasteImage(
            data.image,
            at: data.atIndex,
            moveCursorToPastedContent: data.moveCursor)
    }

    func pasteImages(_ data: (images: [ImageRepresentable], atIndex: Int, moveCursor: Bool)?) {
        guard let data = data else { return }
        textView.pasteImages(
            data.images,
            at: data.atIndex,
            moveCursorToPastedContent: data.moveCursor)
    }

    func pasteText(_ data: (text: String, atIndex: Int, moveCursor: Bool)?) {
        guard let data = data else { return }
        textView.pasteText(
            data.text,
            at: data.atIndex,
            moveCursorToPastedContent: data.moveCursor)
    }

    func redoLatestChange(_ shouldRedo: Bool) {
        guard shouldRedo else { return }
        textView.redoLatestChange()
        syncContextWithTextView()
    }

    func setAlignment(to newValue: RichTextAlignment) {
        if newValue == textView.currentRichTextAlignment { return }
        textView.setCurrentRichTextAlignment(to: newValue)
    }

    func setBackgroundColor(to newValue: ColorRepresentable?) {
        if newValue == textView.currentBackgroundColor { return }
        guard let color = newValue else { return }
        textView.setCurrentBackgroundColor(to: color)
    }

    func setFontName(to newValue: String) {
        if newValue == textView.currentFontName { return }
        textView.setCurrentFontName(to: newValue)
    }

    func setFontSize(to size: CGFloat) {
        if size == textView.currentFontSize { return }
        textView.setCurrentFontSize(to: size)
    }

    func setForegroundColor(to newValue: ColorRepresentable?) {
        if textView.currentForegroundColor == newValue { return }
        guard let color = newValue else { return }
        textView.setCurrentForegroundColor(to: color)
    }

    func setHighlightedRange(to range: NSRange?) {
        resetHighlightedRangeAppearance()
        guard let range = range else { return }
        setHighlightedRangeAppearance(for: range)
    }

    func setHighlightedRangeAppearance(for range: NSRange) {
        highlightedRangeOriginalBackgroundColor = textView.backgroundColor(at: range) ?? .clear
        highlightedRangeOriginalForegroundColor = textView.foregroundColor(at: range) ?? .textColor
        let style = textView.highlightingStyle
        let background = ColorRepresentable(style.backgroundColor)
        let text = ColorRepresentable(style.foregroundColor)
        textView.setBackgroundColor(to: background, at: range)
        textView.setForegroundColor(to: text, at: range)
    }

    func setHighlightingStyle(to style: RichTextHighlightingStyle) {
        textView.highlightingStyle = style
    }

    func setIsEditing(to newValue: Bool) {
        if newValue == textView.isFirstResponder { return }
        if newValue {
            #if os(iOS)
            textView.becomeFirstResponder()
            #else
            textView.window?.makeFirstResponder(textView)
            #endif
        } else {
            #if os(iOS)
            textView.resignFirstResponder()
            #else
            //print("macOS currently doesn't resign first responder.")
            #endif
        }
    }

    func setSelectedRange(to range: NSRange) {
        if range == textView.selectedRange { return }
        textView.selectedRange = range
    }

    func setStyle(_ style: RichTextStyle, to newValue: Bool) {
        let hasStyle = textView.currentRichTextStyles.hasStyle(style)
        if newValue == hasStyle { return }
        textView.textStorage?.beginEditing()
        textView.setCurrentRichTextStyle(style, to: newValue)
        textView.didChangeText()
        textView.textStorage?.endEditing()
    }

    func setStyle(_ style: RichTextNamedStyle.Proto?) {
        guard let style else { return }
        textView.edit(with: style)
    }

    func undoLatestChange(_ shouldUndo: Bool) {
        guard shouldUndo else { return }
        textView.undoLatestChange()
        syncContextWithTextView()
    }
}

private extension ColorRepresentable {

    #if os(iOS) || os(tvOS)
    static var textColor: ColorRepresentable { .label }
    #endif
}
#endif
