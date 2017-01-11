//
//  SimplerTextView.swift
//  Simpler
//
//  Created by Morten Just Petersen on 11/21/15.
//  Copyright © 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import Quartz


protocol VimTextViewDelegate {
  
  func modeDidChange(to mode: VimMode)
}


// TODO (vdka): This is unsatisfactory. Time to write our own TextView.

class VimTextView: NSTextView {
  
  var vimDelegate: VimTextViewDelegate?
  
  var currentMode: VimMode = .normal {
    didSet {
      breakUndoCoalescing()
      vimDelegate?.modeDidChange(to: currentMode)
      redrawCursor()
    }
  }
  
  // A list of all previous key sequences
  var pastKeySequences: [[Key]] = []
  
  // The key sequence currently occuring
  var currentKeySequence: [Key] = []
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    wantsLayer = true
  }
}


// MARK: Input handling

extension VimTextView {
  
  override func keyDown(_ event: NSEvent) {
    
    #if false
      Swift.print("keyCode: \(event.keyCode) characters: \(event.characters)")
    #endif
    
    let key = Key(rawValue: event.characters ?? "")
    
    switch (currentMode, key) {
    case (.normal, let key?):
      
      guard let action = normalModeKeyMap[key] else {
        currentKeySequence.append(key)
        return
      }
      
      for _ in 0..<currentKeySequence.getMultiplier() {
        action(self)
      }
      pastKeySequences.append(currentKeySequence)
      currentKeySequence = []
      
    case (.insert, let key?):
      
      guard let action = insertModeKeyMap[key] else { fallthrough }
      
      action(self)
      
    case (.insert, nil):
      
      super.keyDown(event)
      
    case (.replace, _):
      
      VimVerb.replace(with: event.characters!.characters.first!)(self)
      currentMode = .normal
      
    default:
      
      break
    }
  }
}

extension VimTextView {
  
  func redrawCursor() {
    let charRange = NSRange(location: selectedRange().location, length: 1)
    let glyphRect = self.layoutManager!.boundingRect(forGlyphRange: charRange, in: self.textContainer!)
    setNeedsDisplay(glyphRect)
  }
  
  override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn flag: Bool) {
    
    switch currentMode {
    case .insert:
      super.drawInsertionPoint(in: rect, color: color, turnedOn: flag)
      
    case .normal, .replace:
      let charRange = NSRange(location: selectedRange().location, length: 1)
      var glyphRect = self.layoutManager!.boundingRect(forGlyphRange: charRange, in: self.textContainer!)
      
      defer {
        currentMode == .normal ?
          color.withAlphaComponent(0.5).set() :
          color.withAlphaComponent(0.25).set()
        NSRectFillUsingOperation(glyphRect, NSCompositeSourceOver)
      }
      
    }
  }
  
  override func setNeedsDisplay(_ invalidRect: NSRect) {
    var invalidRect = invalidRect
    
    if case .normal = currentMode {
      invalidRect.size.width += 15
    }
    super.setNeedsDisplay(invalidRect)
  }
}


// MARK: - Movement Commands

extension VimTextView {
  
  var underCursor: Character? {
    
    guard case .normal = currentMode else { return nil }
    
    let characters = Array(self.string!.characters)
    
    guard 0..<characters.count ~= self.selectedRange().location else {
      Swift.print("asdfgjkl")
      return nil
    }
    
    return characters[self.selectedRange().location]
  }
  
  override func moveRight(_ sender: AnyObject?) {
    guard underCursor != "\u{03}" else { return }
    super.moveRight(sender)
  }
  
  override func delete(_ sender: AnyObject?) {
    
    if case .normal = currentMode {
      self.setSelectedRange(NSRange(location: selectedRange().location, length: 1))
    }
    
    super.delete(sender)
  }
}


