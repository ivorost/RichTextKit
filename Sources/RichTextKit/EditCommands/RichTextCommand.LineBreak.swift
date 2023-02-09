//
//  File.swift
//  
//
//  Created by Ivan Kh on 25.01.2023.
//

import Foundation


public extension RichTextCommand {
    class LineBreak: Base {
        public init() {
            super.init(name: .lineBreak)
        }

        public override func apply(in string: NSMutableAttributedString,
                                   range: inout NSRange?) -> [NSAttributedString.Update] {
            guard let theRange = range else { return [] }
            return string.apply(updates: [.replace(range: theRange, string: String.newLine)],
                                range: &range)
        }
    }
}


public extension RichTextCommand.LineBreak {
    class ApplyStyle : RichTextCommand.Base {
        let after: RichTextNamedStyle.Proto
        let before: RichTextNamedStyle.Proto

        public init(before: RichTextNamedStyle.Proto = RichTextNamedStyle.Stub.shared,
                    after: RichTextNamedStyle.Proto = RichTextNamedStyle.Stub.shared) {
            self.before = before
            self.after = after
            super.init(name: .lineBreak)
        }

        public override func before(in attributedString: NSMutableAttributedString,
                                    range: inout NSRange?) -> [NSAttributedString.Update] {
            before.apply(to: attributedString, range: &range)
        }

        override public func after(in attributedString: NSMutableAttributedString,
                                   range: inout NSRange?) -> [NSAttributedString.Update] {
            after.apply(to: attributedString, range: &range)
        }
    }
}

public extension RichTextCommand.LineBreak {
    class Todo : RichTextCommand.Base {
        private var checkNew = false

        public init() {
            super.init(name: .lineBreak)
        }

        public override func before(in string: NSMutableAttributedString,
                                    range: inout NSRange?) -> [NSAttributedString.Update] {

            exec(in: string, range: range) { cell, location in
                guard cell.checked
                else { return }

                guard range?.location == location + 1 && range?.length == 0
                else { return }

                checkNew = true
                cell.checked = false
            }

            return []
        }

        public override func after(in string: NSMutableAttributedString,
                                   range: inout NSRange?) -> [NSAttributedString.Update] {
            guard checkNew else { return [] }

            exec(in: string, range: range) { cell, _ in
                cell.checked = true
                checkNew = false
            }

            return []
        }

        private func exec(in attributedString: NSMutableAttributedString,
                          range: NSRange?,
                          block: (_ cell: RichTextNamedStyle.Todo.Cell, _ location: Int) -> Void) {
            guard let theRange = range
            else { return }

            guard let paragraphRange = attributedString.string.findRangeOfParagraph(from: theRange.location)
            else { return }

            var location: Int?
            guard let cell: RichTextNamedStyle.Todo.Cell = attributedString.attachmentCell(at: paragraphRange,
                                                                                           location: &location),
                  let location
            else { return }

            block(cell, location)
        }
    }
}
