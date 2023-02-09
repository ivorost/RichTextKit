//
//  File.swift
//  
//
//  Created by Ivan Kh on 31.01.2023.
//

import AppKit

extension NSAttributedString {
    func attachmentCell<T>(at range: NSRange, location: inout Int?) -> T? {
        guard range.location < length
        else { return nil }

        guard let attachment = attributedString.attribute(.attachment,
                                                          at: range.location,
                                                          effectiveRange: nil) as? NSTextAttachment
        else { return nil }

        guard let cell = attachment.attachmentCell as? T
        else { return nil }

        location = range.location
        return cell
    }

    func attachmentCell<T>(at range: NSRange) -> T? {
        var location: Int?
        return attachmentCell(at: range, location: &location)
    }

    func hasAttachmentCell(at range: NSRange) -> Bool {
        let cell: NSTextAttachmentCell? = attachmentCell(at: range)
        return cell != nil
    }
}
