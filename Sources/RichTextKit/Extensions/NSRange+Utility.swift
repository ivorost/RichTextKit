//
//  File.swift
//  
//
//  Created by Ivan Kh on 24.01.2023.
//

import Foundation

extension Collection where Element == NSRange {
    var union: NSRange? {
        guard let first else { return nil }

        return reduce(first) { result, current in
            result.union(current)
        }
    }
}

public extension NSRange {
    func applied(_ update: NSAttributedString.Update) -> NSRange? {
        var remove: NSRange?
        var append: Int?

        switch update {
        case .replace(let range, let string):
            remove = range
            append = string.count
        case .replaceAttributed(let range, let attributedString):
            remove = range
            append = attributedString.length
        case .addAttributes(_, _), .removeAttributes(_, _):
            break
        }

        guard let remove, let append else { return self }
        guard remove.location <= upperBound else { return self }

        if remove.upperBound < location {
            return NSRange(location: location + append - remove.length, length: length)
        }

        if length != 0 && remove.location == location && (remove.upperBound < upperBound || remove.length == 0) {
            return NSRange(location: location, length: length - remove.length + append)
        }

        if remove.location <= location && remove.upperBound <= location {
            return NSRange(location: location + append - remove.length, length: length)
        }

        if remove.location < location && remove.upperBound >= upperBound {
            return nil
        }

        if remove.location == location && remove.upperBound > upperBound {
            return nil
        }

        if remove.location < location && remove.upperBound > location {
            return NSRange(location: remove.location + append, length: upperBound - remove.upperBound)
        }

        if remove.location >= location && remove.upperBound <= upperBound {
            return NSRange(location: location, length: length + append - remove.length)
        }

        if remove.location >= location && remove.upperBound > upperBound {
            return NSRange(location: location, length: remove.location - location)
        }

        assertionFailure()
        return self
    }

    func applied(_ updates: [NSAttributedString.Update]) -> NSRange? {
        updates.reduce(self as NSRange?) { $0?.applied($1) }
    }
}
