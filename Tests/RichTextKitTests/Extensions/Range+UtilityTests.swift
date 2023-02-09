//
//  File.swift
//  
//
//  Created by Ivan Kh on 25.01.2023.
//

import RichTextKit
import XCTest

class Range_UtilityTests: XCTestCase {

    func update1(_ update: NSAttributedString.Update) -> NSRange? {
        NSRange(location: 3, length: 4).applied(update)
    }

    func update2(_ update: NSAttributedString.Update) -> NSRange? {
        NSRange(location: 2, length: 0).applied(update)
    }

    func testIndexOfCurrentParagraphIsCorrectForEmptyString() {
        // Useful string for testing "0123456789"

        XCTAssertEqual(update1(.replace(range: NSRange(location: 1, length: 1), string: "asd")),
                       NSRange(location: 5, length: 4))
        XCTAssertEqual(update1(.replace(range: NSRange(location: 1, length: 5), string: "asd")),
                       NSRange(location: 4, length: 1))
        XCTAssertEqual(update1(.replace(range: NSRange(location: 3, length: 0), string: "asd")),
                       NSRange(location: 3, length: 7))
        XCTAssertEqual(update1(.replace(range: NSRange(location: 3, length: 4), string: "asd")),
                       NSRange(location: 3, length: 3))
        XCTAssertEqual(update1(.replace(range: NSRange(location: 3, length: 5), string: "asd")),
                       nil)
        XCTAssertEqual(update1(.replace(range: NSRange(location: 2, length: 5), string: "asd")),
                       nil)
        XCTAssertEqual(update1(.replace(range: NSRange(location: 4, length: 2), string: "asd")),
                       NSRange(location: 3, length: 5))
        XCTAssertEqual(update1(.replace(range: NSRange(location: 5, length: 4), string: "asd")),
                       NSRange(location: 3, length: 2))
        XCTAssertEqual(update1(.replace(range: NSRange(location: 7, length: 2), string: "asd")),
                       NSRange(location: 3, length: 4))
        XCTAssertEqual(update2(.replace(range: NSRange(location: 0, length: 2), string: "")),
                       NSRange(location: 0, length: 0))
    }
}
