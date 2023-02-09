//
//  File.swift
//  
//
//  Created by Ivan Kh on 01.02.2023.
//

import AppKit

protocol NSTextAttachmentClickableCell {
    func clicked(textView: NSTextView, in cellFrame: NSRect, at charIndex: Int)
}
