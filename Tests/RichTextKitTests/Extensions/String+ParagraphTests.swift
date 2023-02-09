//
//  String+ParagraphTests.swift
//  RichTextKitTests
//
//  Created by Daniel Saidi on 2021-12-30.
//  Copyright © 2021 Daniel Saidi. All rights reserved.
//

import RichTextKit
import XCTest

class String_ParagraphTests: XCTestCase {
    
    let none = "foo bar baz"
    let single = "foo\nbar baz"
    let multi = "foo\nbar\rbaz"
    let empty = "foo\n\nbaz"
    let emptyAtTheBeginning = "\na"
    let emptyAtTheEnd = "a\n"
    let twoLineBreaks = "a\n\n"
    let unicode = "🍔\n👼\n"

    func currentResult(for string: String, from location: UInt) -> UInt {
        string.findIndexOfCurrentParagraph(from: location)
    }

    func currentRanges(for string: String, from range: NSRange) -> [NSRange] {
        string.findRangesOfParagraphs(in: range)
    }

    func prevResult(for string: String, from location: Int) -> NSRange? {
        string.findRangeOfPreviousParagraph(from: location)
    }

    func nextResult(for string: String, from location: UInt) -> UInt {
        string.findIndexOfNextParagraphOrCurrent(from: location)
    }


    func testIndexOfCurrentParagraphIsCorrectForEmptyString() {
        XCTAssertEqual(currentResult(for: "", from: 0), 0)
        XCTAssertEqual(currentResult(for: "", from: 20), 0)
    }

    func testIndexOfCurrentParagraphIsCorrectForStringWithNoPreviousParagraph() {
        XCTAssertEqual(currentResult(for: none, from: 0), 0)
        XCTAssertEqual(currentResult(for: none, from: 10), 0)
        XCTAssertEqual(currentResult(for: none, from: 20), 0)
    }

    func testIndexOfCurrentParagraphIsCorrectForStringWithSinglePreviousParagraph() {
        XCTAssertEqual(currentResult(for: single, from: 0), 0)
        XCTAssertEqual(currentResult(for: single, from: 5), 4)
        XCTAssertEqual(currentResult(for: single, from: 10), 4)
    }

    func testIndexOfCurrentParagraphIsCorrectForStringWithManyPreviousParagraphs() {
        XCTAssertEqual(currentResult(for: multi, from: 0), 0)
        XCTAssertEqual(currentResult(for: multi, from: 5), 4)
        XCTAssertEqual(currentResult(for: multi, from: 10), 8)
    }

    func testIndexOfCurrentParagraphIsCorrectForStringWithEmptyParagraphs() {
        XCTAssertEqual(currentResult(for: empty, from: 4), 4)
        XCTAssertEqual(currentResult(for: emptyAtTheBeginning, from: 0), 0)
        XCTAssertEqual(currentResult(for: emptyAtTheEnd, from: 2), 2)
    }

    func testIndexOfCurrentParagraphIsCorrectForUnicodeString() {
        XCTAssertEqual(currentResult(for: unicode, from: 0), 0)
        XCTAssertEqual(currentResult(for: unicode, from: 1), 0)
        XCTAssertEqual(currentResult(for: unicode, from: 2), 0)
        XCTAssertEqual(currentResult(for: unicode, from: 3), 3)
        XCTAssertEqual(currentResult(for: unicode, from: 4), 3)
        XCTAssertEqual(currentResult(for: unicode, from: 5), 3)
    }

    func testRangeOfCurrentParagraphIsCorrectForEmptyString() {
        XCTAssertEqual(currentRanges(for: "", from: NSRange(location: 0, length: 0)),
                       [NSRange(location: 0, length: 0)])
        XCTAssertEqual(currentRanges(for: "", from: NSRange(location: 20, length: 0)),
                       [])
        XCTAssertEqual(currentRanges(for: "", from: NSRange(location: 20, length: 20)),
                       [])
    }

    func testRangeOfCurrentParagraphIsCorrectForStringWithOneParagraph() {
        XCTAssertEqual(currentRanges(for: none, from: NSRange(location: 0, length: 0)),
                       [NSRange(location: 0, length: none.count)])
        XCTAssertEqual(currentRanges(for: none, from: NSRange(location: 5, length: 2)),
                       [NSRange(location: 0, length: none.count)])
        XCTAssertEqual(currentRanges(for: none, from: NSRange(location: 11, length: 0)),
                       [NSRange(location: 0, length: none.count)])
        XCTAssertEqual(currentRanges(for: none, from: NSRange(location: 20, length: 0)),
                       [])
        XCTAssertEqual(currentRanges(for: none, from: NSRange(location: 20, length: 20)),
                       [])
    }

    func testRangeOfCurrentParagraphIsCorrectForStringWithTwoParagraph() {
        XCTAssertEqual(currentRanges(for: single, from: NSRange(location: 0, length: 0)),
                       [NSRange(location: 0, length: 3)])
        XCTAssertEqual(currentRanges(for: single, from: NSRange(location: 5, length: 1)),
                       [NSRange(location: 4, length: 7)])
        XCTAssertEqual(currentRanges(for: single, from: NSRange(location: 2, length: 4)),
                       [NSRange(location: 0, length: 3), NSRange(location: 4, length: 7)])
    }

    func testRangeOfCurrentParagraphIsCorrectForStringWithThreeParagraphs() {
        XCTAssertEqual(currentRanges(for: multi, from: NSRange(location: 5, length: 0)),
                       [NSRange(location: 4, length: 3)])
        XCTAssertEqual(currentRanges(for: multi, from: NSRange(location: 10, length: 0)),
                       [NSRange(location: 8, length: 3)])
        XCTAssertEqual(currentRanges(for: multi, from: NSRange(location: 2, length: 10)),
                       [NSRange(location: 0, length: 3),
                        NSRange(location: 4, length: 3),
                        NSRange(location: 8, length: 3)])
    }

    func testRangeOfCurrentParagraphIsCorrectForStringWithEmptyParagraph() {
        XCTAssertEqual(currentRanges(for: empty, from: NSRange(location: 4, length: 0)),
                       [NSRange(location: 4, length: 0)])
        XCTAssertEqual(currentRanges(for: empty, from: NSRange(location: 0, length: 8)),
                       [NSRange(location: 0, length: 3),
                        NSRange(location: 4, length: 0),
                        NSRange(location: 5, length: 3)])
        XCTAssertEqual(currentRanges(for: emptyAtTheBeginning, from: NSRange(location: 0, length: 0)),
                       [NSRange(location: 0, length: 0)])
        XCTAssertEqual(currentRanges(for: emptyAtTheBeginning, from: NSRange(location: 0, length: 2)),
                       [NSRange(location: 0, length: 0),
                        NSRange(location: 1, length: 1)])
        XCTAssertEqual(currentRanges(for: emptyAtTheEnd, from: NSRange(location: 0, length: 1)),
                       [NSRange(location: 0, length: 1)])
        XCTAssertEqual(currentRanges(for: emptyAtTheEnd, from: NSRange(location: 2, length: 0)),
                       [NSRange(location: 2, length: 0)])
        XCTAssertEqual(currentRanges(for: emptyAtTheEnd, from: NSRange(location: 0, length: 2)),
                       [NSRange(location: 0, length: 1),
                        NSRange(location: 2, length: 0)])
    }


    func testIndexOfPrevParagraphIsCorrectForEmptyString() {
        XCTAssertEqual(prevResult(for: "", from: 0), nil)
        XCTAssertEqual(prevResult(for: "", from: 20), nil)
    }

    func testIndexOfPrevParagraphIsCorrectForStringWithNoPrevParagraph() {
        XCTAssertEqual(prevResult(for: none, from: 0), nil)
        XCTAssertEqual(prevResult(for: none, from: 10), nil)
        XCTAssertEqual(prevResult(for: none, from: 20), nil)
    }

    func testIndexOfPrevParagraphIsCorrectForStringWithSinglePrevParagraph() {
        XCTAssertEqual(prevResult(for: single, from: 5), NSRange(location: 0, length: 3))
        XCTAssertEqual(prevResult(for: single, from: 10), NSRange(location: 0, length: 3))
    }

    func testIndexOfPrevParagraphIsCorrectForStringWithMultiplePrevParagraphs() {
        XCTAssertEqual(prevResult(for: multi, from: 0), nil)
        XCTAssertEqual(prevResult(for: multi, from: 5), NSRange(location: 0, length: 3))
        XCTAssertEqual(prevResult(for: multi, from: 10), NSRange(location: 4, length: 3))
    }

    func testIndexOfPrevParagraphIsCorrectForStringWithEmptyPrevParagraphs() {
        XCTAssertEqual(prevResult(for: empty, from: 7), NSRange(location: 4, length: 0))
    }

    func testIndexOfPrevParagraphIsCorrectForStringWithTwoLineBreaks() {
        XCTAssertEqual(prevResult(for: twoLineBreaks, from: 2), NSRange(location: 0, length: 1))
    }


    func testIndexOfNextParagraphIsCorrectForEmptyString() {
        XCTAssertEqual(nextResult(for: "", from: 0), 0)
        XCTAssertEqual(nextResult(for: "", from: 20), 0)
    }

    func testIndexOfNextParagraphIsCorrectForStringWithNoNextParagraph() {
        XCTAssertEqual(nextResult(for: none, from: 0), 0)
        XCTAssertEqual(nextResult(for: none, from: 10), 0)
        XCTAssertEqual(nextResult(for: none, from: 20), 0)
    }

    func testIndexOfNextParagraphIsCorrectForStringWithSingleNextParagraph() {
        XCTAssertEqual(nextResult(for: single, from: 0), 4)
        XCTAssertEqual(nextResult(for: single, from: 5), 4)
        XCTAssertEqual(nextResult(for: single, from: 10), 4)
    }

    func testIndexOfNextParagraphIsCorrectForStringWithMultipleNextParagraphs() {
        XCTAssertEqual(nextResult(for: multi, from: 0), 4)
        XCTAssertEqual(nextResult(for: multi, from: 5), 8)
        XCTAssertEqual(nextResult(for: multi, from: 10), 8)
    }
}
