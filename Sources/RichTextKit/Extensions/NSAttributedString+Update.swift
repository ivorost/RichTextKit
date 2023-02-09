//
//  File.swift
//  
//
//  Created by Ivan Kh on 24.01.2023.
//

import Foundation

public extension NSAttributedString {
    enum Update {
        case replace(range: NSRange, string: String)
        case replaceAttributed(range: NSRange, string: NSAttributedString)
        case addAttributes(range: NSRange, attributes: [NSAttributedString.Key : Any])
        case removeAttributes(range: NSRange, attributes: [NSAttributedString.Key])
    }
}

public extension NSMutableAttributedString {
    @discardableResult func apply(_ updates: [NSAttributedString.Update]) -> [NSAttributedString.Update] {
        updates.forEach { apply($0) }
        return updates
    }

    @discardableResult func apply(_ update: NSAttributedString.Update) -> NSAttributedString.Update {
        switch update {
        case .replace(let range, let string):
            replaceCharacters(in: range, with: string)

        case .replaceAttributed(let range, let string):
            replaceCharacters(in: range, with: string)

        case .addAttributes(let range, let attributes):
            addAttributes(attributes, range: range)

        case .removeAttributes(let range, let attributes):
            attributes.forEach { removeAttribute($0, range: range) }
        }

        return update
    }

    @discardableResult func apply(updates: [NSAttributedString.Update],
                                  range: inout NSRange?) -> [NSAttributedString.Update] {
        range = range?.applied(updates)
        return apply(updates)
    }

    @discardableResult func apply(update: NSAttributedString.Update,
                                  range: inout NSRange?) -> NSAttributedString.Update {
        range = range?.applied(update)
        return apply(update)
    }
}
