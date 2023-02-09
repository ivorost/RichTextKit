//
//  File.swift
//  
//
//  Created by Ivan Kh on 25.01.2023.
//

import Foundation

public struct RichTextCommand {}

public protocol RichTextCommandProtocol {
    func matches(command: String) -> Bool
    func before(in string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update]
    func apply(in string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update]
    func after(in string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update]
}

public extension RichTextCommand {
    typealias Proto = RichTextCommandProtocol
}

public extension RichTextCommand {
    class Base : Proto {
        private let command: String

        public init(command: String) {
            self.command = command
        }

        public init(name: Name) {
            self.command = name.rawValue
        }

        public func matches(command: String) -> Bool {
            return self.command == command
        }

        public func before(in string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            return []
        }

        public func apply(in string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            return []
        }

        public func after(in string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
            return []
        }
    }
}

public extension RichTextCommand {
    enum Name : String {
        case lineBreak = "lineBreak"
    }
}

public extension RichTextCommand.Name {
    private static var map: [String: Self] = [
        "insertNewline:" : .lineBreak
    ]

    static func create(rawValue: String) -> Self? {
        if let result = Self(rawValue: rawValue) {
            return result
        }

        if let result = Self.map[rawValue] {
            return result
        }

        return nil
    }

}


extension Sequence where Element == any RichTextCommand.Proto {
    public func matches(command: String) -> [RichTextCommand.Proto] {
        filter { $0.matches(command: command) }
    }

    public func before(in string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
        reduce([NSAttributedString.Update]()) { $0 + $1.before(in: string, range: &range) }
    }

    public func apply(in string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
        reduce([NSAttributedString.Update]()) { $0 + $1.apply(in: string, range: &range) }
    }

    public func after(in string: NSMutableAttributedString, range: inout NSRange?) -> [NSAttributedString.Update] {
        reduce([NSAttributedString.Update]()) { $0 + $1.after(in: string, range: &range) }
    }
}
