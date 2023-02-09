//
//  File.swift
//  
//
//  Created by Ivan Kh on 16.02.2023.
//

import AppKit

extension RichTextNamedStyle {
    class Cell: NSTextAttachmentCell {
        private weak var textView: NSTextView?

        func setNeedsDisplay(at range: NSRange) {
            textView?.layoutManager?.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
            textView?.layoutManager?.invalidateDisplay(forCharacterRange: range)
        }

        public override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
            // Note: This API runs whenever we're in display mode
            textView = controlView as? NSTextView
        }

        public override func draw(withFrame cellFrame: NSRect, in controlView: NSView?, characterIndex charIndex: Int) {
            // Note: This API is expected to run when we're editing Tags
            textView = controlView as? NSTextView
        }
    }
}
