//
//  RichTextCoordinator.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-05-22.
//  Copyright © 2022 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(tvOS)
import Combine
import SwiftUI

/**
 This coordinator is used to keep a ``RichTextView`` in sync
 with a ``RichTextContext``.

 The coordinator sets itself as the text view's delegate and
 updates the context when things change in the text view. It
 also subscribes to context observable changes and keeps the
 text view in sync with these changes.

 You can inherit this class to customize the coordinator for
 your own use cases.
 */
open class RichTextCoordinator: NSObject {

    // MARK: - Initialization

    /**
     Create a rich text coordinator.

     - Parameters:
       - text: The rich text to edit.
       - textView: The rich text view to keep in sync.
       - richTextContext: The context to keep in sync.
     */
    public init(
        text: Binding<NSAttributedString>,
        textView: RichTextView,
        containerView: NSView,
        richTextContext: RichTextContext
    ) {
        self.text = text
        self.textView = textView
        self.richTextContext = richTextContext
        self.containerView = containerView
        super.init()
        self.textView.delegate = self
        richTextContext.content = text.wrappedValue
        subscribeToContextChanges()

        self.textView.commandWrapper = { [weak self] name, apply in
            self?.commandWrapper(name: name, apply: apply)
        }

        self.textView.copyWrapper = { [weak self] apply in
            self?.copyWrapper(apply: apply)
        }
    }


    // MARK: - Properties

    private(set) var syncingContext = false

    /**
     The rich text context for which the coordinator is used.
     */
    public let richTextContext: RichTextContext

    /**
     The rich text to edit.
     */
    public var text: Binding<NSAttributedString>

    /**
     Container
     */
    public private(set) var containerView: NSView

    /**
     The text view for which the coordinator is used.
     */
    public private(set) var textView: RichTextView

    /**
     This set is used to store context observations.
     */
    public var cancellables = Set<AnyCancellable>()

    /**
     This test flag is used to avoid delaying context sync.
     */
    internal var shouldDelaySyncContextWithTextView = true


    // MARK: - Internal Properties

    /**
     The background color that was used before the currently
     highlighted range was set.
     */
    internal var highlightedRangeOriginalBackgroundColor: ColorRepresentable?

    /**
     The foreground color that was used before the currently
     highlighted range was set.
     */
    internal var highlightedRangeOriginalForegroundColor: ColorRepresentable?

    private func commandWrapper(name: String, apply: () -> Void) {
        var commandName = name
        var range: NSRange?

        if let knownName = RichTextCommand.Name.create(rawValue: commandName) {
            commandName = knownName.rawValue
        }

        let commands = richTextContext
            .commandHandlers
            .matches(command: commandName)

        guard commands.count > 0 else {
            apply()
            return
        }

        textView.edit {
            var attributedString: NSMutableAttributedString

            range = textView.selectedRange()
            attributedString = NSMutableAttributedString(attributedString: textView.attributedString())
            textView.apply(commands.before(in: attributedString, range: &range))

            let applyUpdates = commands.apply(in: attributedString, range: &range)

            if applyUpdates.count > 0 {
                textView.apply(applyUpdates)
            }
            else {
                apply()
                range = textView.selectedRange()
                attributedString = NSMutableAttributedString(attributedString: textView.attributedString())
            }

            textView.apply(commands.after(in: attributedString, range: &range))
        }

        if let range {
            textView.setSelectedRange(range)
        }
    }

    private func copyWrapper(apply: () -> Void) {
        let string = NSMutableAttributedString(attributedString: textView.attributedString())
        var range: NSRange? = NSRange(location: 0, length: string.length)

        _ = richTextContext.copyStyles.apply(to: string, range: &range)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([string])
    }

    #if canImport(UIKit)

    // MARK: - UITextViewDelegate

    open func textViewDidBeginEditing(_ textView: UITextView) {
        richTextContext.isEditingText = true
    }

    open func textViewDidChange(_ textView: UITextView) {
        syncWithTextView()
    }

    open func textViewDidChangeSelection(_ textView: UITextView) {
        syncWithTextView()
    }

    open func textViewDidEndEditing(_ textView: UITextView) {
        richTextContext.isEditingText = false
    }
    #endif


    #if canImport(AppKit)

    // MARK: - NSTextViewDelegate

    open func textDidBeginEditing(_ notification: Notification) {
        richTextContext.isEditingText = true
    }

    open func textDidChange(_ notification: Notification) {
        syncWithTextView()
    }

    public func textView(_ textView: NSTextView,
                         willChangeSelectionFromCharacterRange oldSelectedCharRange: NSRange,
                         toCharacterRange newSelectedCharRange: NSRange) -> NSRange {

        if newSelectedCharRange.length == 0
            && textView.attributedString().hasAttachmentCell(at: newSelectedCharRange) {

            let direction = oldSelectedCharRange.location > newSelectedCharRange.location ? -1 : 1
            let newLocation = min(textView.attributedString().length - 1,
                                  max(1, newSelectedCharRange.location + direction))

            return NSRange(location: newLocation, length: 0)
        }

        return newSelectedCharRange
    }

    public func textView(_ textView: NSTextView,
                         shouldChangeTextIn affectedCharRange: NSRange,
                         replacementString: String?) -> Bool {
        return replacementString != "\t"
    }

    open func textViewDidChangeSelection(_ notification: Notification) {
        guard richTextContext.selectedRange != textView.selectedRange() else { return }

        syncContextWithTextView()

        let location = max(0, min(textView.attributedString().length - 1, textView.selectedRange().location - 1))

        if textView.attributedString().length > 0 {
            textView.typingAttributes = textView.attributedString().attributes(at: location, effectiveRange: nil)
        }
    }

    open func textDidEndEditing(_ notification: Notification) {
        richTextContext.isEditingText = false
    }

    public func textView(_ textView: NSTextView,
                         clickedOn cell: NSTextAttachmentCellProtocol,
                         in cellFrame: NSRect,
                         at charIndex: Int) {
        if let cell = cell as? NSTextAttachmentClickableCell {
            cell.clicked(textView: textView, in: cellFrame, at: charIndex)
        }
    }

    #endif
}


#if os(iOS) || os(tvOS)
import UIKit

extension RichTextCoordinator: UITextViewDelegate {}

#elseif os(macOS)
import AppKit

extension RichTextCoordinator: NSTextViewDelegate {}
#endif


// MARK: - Public Extensions

public extension RichTextCoordinator {

    /**
     Reset the apperance for the currently highlighted range,
     if any.
     */
    func resetHighlightedRangeAppearance() {
        guard
            let range = richTextContext.highlightedRange,
            let background = highlightedRangeOriginalBackgroundColor,
            let text = highlightedRangeOriginalForegroundColor
        else { return }
        textView.setBackgroundColor(to: background, at: range)
        textView.setForegroundColor(to: text, at: range)
    }
}


// MARK: - Internal Extensions

extension RichTextCoordinator {

    /**
     Sync state from the text view's current state.
     */
    func syncWithTextView() {
        syncContextWithTextView()
        syncTextWithTextView()
    }

    /**
     Sync the rich text context with the text view.
     */
    func syncContextWithTextView() {
        if shouldDelaySyncContextWithTextView {
            DispatchQueue.main.async {
                self.syncContextWithTextViewAfterDelay()
            }
        } else {
            syncContextWithTextViewAfterDelay()
        }
    }

    /**
     Sync the rich text context with the text view after the
     dispatch queue delay above. The delay will silence some
     purple alert warnings about how state is updated.
     */
    func syncContextWithTextViewAfterDelay() {
        syncingContext = true

        defer {
            syncingContext = false
        }

        let styles = textView.currentRichTextStyles

        let content = textView.attributedString
        if richTextContext.content != content {
            richTextContext.content = content
        }

        let range = textView.selectedRange
        if richTextContext.selectedRange != range {
            richTextContext.selectedRange = range
        }

        let background = textView.currentBackgroundColor
        if richTextContext.backgroundColor != background {
            richTextContext.backgroundColor = background
        }

        let hasRange = textView.hasSelectedRange
        if richTextContext.canCopy != hasRange {
            richTextContext.canCopy = hasRange
        }

        let canRedo = textView.undoManager?.canRedo ?? false
        if richTextContext.canRedoLatestChange != canRedo {
            richTextContext.canRedoLatestChange = canRedo
        }

        let canUndo = textView.undoManager?.canUndo ?? false
        if richTextContext.canUndoLatestChange != canUndo {
            richTextContext.canUndoLatestChange = canUndo
        }

        let fontName = textView.currentFontName ?? ""
        if richTextContext.fontName != fontName {
            richTextContext.fontName = fontName
        }

        let fontSize = textView.currentFontSize ?? .standardRichTextFontSize
        if richTextContext.fontSize != fontSize {
            richTextContext.fontSize = fontSize
        }

        let foreground = textView.currentForegroundColor
        if richTextContext.foregroundColor != foreground {
            richTextContext.foregroundColor = foreground
        }

        let isBold = styles.hasStyle(.bold)
        if richTextContext.isBold != isBold {
            richTextContext.isBold = isBold
        }

        let isItalic = styles.hasStyle(.italic)
        if richTextContext.isItalic != isItalic {
            richTextContext.isItalic = isItalic
        }

        let isStrikethrough = styles.hasStyle(.strikethrough)
        if richTextContext.isStrikethrough != isStrikethrough {
            richTextContext.isStrikethrough = isStrikethrough
        }

        let isUnderlined = styles.hasStyle(.underlined)
        if richTextContext.isUnderlined != isUnderlined {
            richTextContext.isUnderlined = isUnderlined
        }

        let isEditingText = textView.isFirstResponder
        if richTextContext.isEditingText != isEditingText {
            richTextContext.isEditingText = isEditingText
        }

        let textAlignment = textView.currentRichTextAlignment ?? .left
        if richTextContext.textAlignment != textAlignment {
            richTextContext.textAlignment = textAlignment
        }

        let namedStyle = richTextContext.namedStyles.firstNamedStyle(textView.attributedString,
                                                                     textView.selectedRange)
        if richTextContext.namedStyle !== namedStyle {
            richTextContext.namedStyle = namedStyle
        }
    }

    /**
     Sync the text binding with the text view.
     */
    func syncTextWithTextView() {
        DispatchQueue.main.async {
            self.text.wrappedValue = self.textView.attributedString
        }
    }
}
#endif
