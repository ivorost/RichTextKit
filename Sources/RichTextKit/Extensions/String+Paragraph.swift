//
//  String+Paragraph.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-05-29.
//  Copyright © 2022 Daniel Saidi. All rights reserved.
//

import Foundation

fileprivate extension Character {
    init?(_ unichar: unichar) {
        guard let unicodeScalar = UnicodeScalar(unichar) else { return nil }
        self.init(unicodeScalar)
    }
}

fileprivate extension NSString {
    var last: unichar? {
        length > 0 ? character(at: length - 1) : nil
    }

    var lastUnicode: Character? {
        guard let last else { return nil }
        return Character(last)
    }

    func unicodeCharacter(at index: Int) -> Character? {
        guard index < length else { return nil }
        return Character(character(at: index))
    }

    func unicodeCharacter(at index: UInt) -> Character? {
        unicodeCharacter(at: Int(index))
    }

    var isEmpty: Bool {
        return length == 0
    }
}

public extension NSString {
    
    /**
     Backs to find the index of the first new line paragraph
     before the provided location, if any.
     
     A new paragraph is considered to start at the character
     after the newline char, not the newline itself.
     */
    func findIndexOfCurrentParagraph(from location: UInt) -> UInt {
        if location == length, length > 0, lastUnicode?.isNewline == true {
            return location
        }

        if isEmpty { return 0 }
        let count = UInt(length)
        var index = min(location, UInt(length)-1)
        repeat {
            guard index > 0, index < count else { break }
            if unicodeCharacter(at: index - 1)?.isNewline == true { break }
            index -= 1
        } while true
        return max(index, 0)
    }

    func findRangesOfParagraphs(in range: NSRange) -> [NSRange] {
        guard range.location <= length else { return [] }

        if range.location == 0, range.length == 0, length == 0 {
            return [NSRange()]
        }

        var location = findIndexOfCurrentParagraph(from: UInt(max(range.location, 0)))
        var length = 0
        var index = location
        var result = [NSRange]()

        guard location != self.length else { return [NSRange(location: Int(location), length: 0)] }

        repeat {
            guard index >= 0, index < self.length else { break }

            if unicodeCharacter(at: index)?.isNewline == true {
                result.append(NSRange(location: Int(location), length: length))

                index += 1
                location = index
                length = 0

                if index >= range.upperBound {
                    break
                }
            }
            else {
                index += 1
                length += 1
            }
        } while true

        if length > 0 || (range.upperBound == self.length && lastUnicode?.isNewline == true) {
            result.append(NSRange(location: Int(location), length: length))
        }

        return result
    }

    func findRangeOfParagraph(from location: Int) -> NSRange? {
        return findRangesOfParagraphs(in: NSRange(location: location, length: 0)).first
    }

    func findRangeOfPreviousParagraph(from location: Int) -> NSRange? {
        var index = location - 1

        repeat {
            guard index >= 0 else { break }
            if unicodeCharacter(at: index)?.isNewline == true { break }
            index -= 1
        } while true

        guard index >= 0 else { return nil }
        guard index < length else { return nil }

        let start = Int(findIndexOfCurrentParagraph(from: UInt(index)))
        return NSRange(location: start, length: index - start)
    }

    func findIndexOfNextParagraph(from location: UInt) -> UInt? {
        var index = location
        repeat {
            let char = unicodeCharacter(at: index)
            index += 1
            guard index < length else { break }
            if char?.isNewline == true { break }
        } while true
        let found = index < length
        return found ? index : nil
    }

    /**
     Looks forward to find the next new line paragraph after
     the provided location, if any. If no next paragraph can
     be found, the current is returned.
     
     A new paragraph is considered to start at the character
     after the newline char, not the newline itself.
     */
    func findIndexOfNextParagraphOrCurrent(from location: UInt) -> UInt {
        var index = location
        repeat {
            let char = unicodeCharacter(at: index)
            index += 1
            guard index < length else { break }
            if char?.isNewline == true { break }
        } while true
        let found = index < length
        return found ? index : findIndexOfCurrentParagraph(from: location)
    }

    func findRangeOfNextParagraph(from location: UInt) -> NSRange? {
        guard var index = findIndexOfNextParagraph(from: location) else { return nil }
        var result = NSRange(location: Int(index), length: 0)

        repeat {
            if unicodeCharacter(at: index)?.isNewline == true { break }
            index += 1
            result.length += 1
        } while index < length

        return result
    }
}
