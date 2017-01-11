//
//  Vim.swift
//  Scode
//
//  Created by Ethan Jackwitz on 6/16/16.
//  Copyright © 2016 Ethan Jackwitz. All rights reserved.
//

import AppKit

// MARK: - Modes

enum VimMode: String {
  case normal
  case insert
  case replace
}


// MARK: - Keys

enum Key: String {
  case a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
  case A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z
  
  case num0 = "0"
  case num1 = "1"
  case num2 = "2"
  case num3 = "3"
  case num4 = "4"
  case num5 = "5"
  case num6 = "6"
  case num7 = "7"
  case num8 = "8"
  case num9 = "9"
  
  case bang = "!"
  case atmark = "@"
  case hash = "#"
  case dollar = "$"
  case percent = "%"
  case carot = "^"
  case ampersand = "&"
  case asterisk = "*"
  case leftBracket = "("
  case rightBracket = ")"

  case esc = "\u{1B}"
}

enum Direction {
  case left
  case right
  case up
  case down
}

enum VimVerb {
  
  static func undo(in textView: VimTextView) {
    textView.undoManager?.undoNestedGroup()
  }
  
  static func delete(in textView: VimTextView) {
    textView.delete(nil)
  }

  static func replace(with character: Character) -> (VimTextView) -> Void {
    return {
      $0.delete(nil)
      $0.insertText(String(character), replacementRange: NSRange(location: $0.selectedRange().location, length: 1))
      $0.moveLeft(nil)
    }
  }
  
  static func deleteAndEnterInsertMode(in textView: VimTextView) {
    textView.delete(nil)
    textView.currentMode = .insert
  }
  
  static func copy(in textView: VimTextView) {
    textView.copy(nil)
  }
}

enum Where {
  case above
  case below
}

enum VimMotion {
  
  static func move(_ direction: Direction) -> (VimTextView) -> Void {
    
    switch direction {
    case .left: return { $0.moveLeft(nil) }
    case .right: return { $0.moveRight(nil) }
    case .up: return { $0.moveUp(nil) }
    case .down: return { $0.moveDown(nil) }
    }
  }
  
  static func insert(_ place: Where) -> (VimTextView) -> Void {
    
    switch place {
    case .below: return {
        VimMotion.moveToEndOfLine(in: $0)
        $0.insertNewline(nil)
        VimModeSwitch.enterInsertMode(in: $0)
      }
    case .above:
      
      return {
        VimMotion.move(.up)($0)
        VimMotion.moveToEndOfLine(in: $0)
        $0.insertNewline(nil)
        VimModeSwitch.enterInsertMode(in: $0)
      }
    }
  }
  
  static func moveToStartOfWord(in textView: VimTextView) {
    textView.moveWordLeft(nil)
  }
  
  static func moveToEndOfWord(in textView: VimTextView) {
    textView.moveWordRight(nil)
  }
  
  static func moveToStartOfLine(in textView: VimTextView) {
    textView.moveToBeginningOfLine(nil)
  }
  
  static func moveToEndOfLine(in textView: VimTextView) {
    textView.moveToEndOfLine(nil)
  }
}

enum VimModeSwitch {
  
  static func enterInsertMode(in textView: VimTextView) {
    textView.currentMode = .insert
  }
  
  static func enterNormalMode(in textView: VimTextView) {
    textView.currentMode = .normal
  }
  
  static func enterReplaceMode(in textView: VimTextView) {
    textView.currentMode = .replace
  }
}


// MARK: - Key bindings

var normalModeKeyMap: [Key: (VimTextView) -> Void] = [
  .h: VimMotion.move(.left),
  .j: VimMotion.move(.down),
  .k: VimMotion.move(.up),
  .l: VimMotion.move(.right),
  .b: VimMotion.moveToStartOfWord,
  .e: inSequence([VimMotion.moveToEndOfWord, VimMotion.move(.left)]),
  .w: inSequence([VimMotion.moveToEndOfWord, VimMotion.move(.right)]),
  .i: VimModeSwitch.enterInsertMode,
  .a: inSequence([VimMotion.move(.right), VimModeSwitch.enterInsertMode]),
  .A: inSequence([VimMotion.moveToEndOfLine, VimModeSwitch.enterInsertMode]),
  .o: VimMotion.insert(.below),
  .O: VimMotion.insert(.above),
  .J: inSequence([VimMotion.moveToEndOfLine, VimVerb.replace(with: " ")]),
  .y: VimVerb.copy,
  .u: VimVerb.undo,
  .x: VimVerb.delete,
  .s: VimVerb.deleteAndEnterInsertMode,
  .r: VimModeSwitch.enterReplaceMode,
  .dollar: VimMotion.moveToEndOfLine,
  .num0: VimMotion.moveToStartOfLine
]

var insertModeKeyMap: [Key: (VimTextView) -> Void] = [
  .esc: VimModeSwitch.enterNormalMode
]

extension Collection where Self.Iterator.Element == Key {
  
  func getMultiplier() -> Int {
    
    // FIXME: bad name
    let validNumeralBeginnings: Set<Key> = [.num1, .num2, .num3, .num4, .num5, .num6, .num7, .num8, .num9]
    let numerals = validNumeralBeginnings.union([.num0])
    
    guard let first = self.first else { return 1 }
    guard validNumeralBeginnings.contains(first) else { return 1 }
    
    var number = 0
    
    for digit in self where numerals.contains(digit) {
      let digitValue = Int(digit.rawValue)!
      
      number *= 10
      number += digitValue
    }
    
    return number
  }
}








