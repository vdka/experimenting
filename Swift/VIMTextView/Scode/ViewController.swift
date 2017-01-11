//
//  ViewController.swift
//  Scode
//
//  Created by Ethan Jackwitz on 6/16/16.
//  Copyright © 2016 Ethan Jackwitz. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, VimTextViewDelegate {

  @IBOutlet var sourceTextView: VimTextView!
  @IBOutlet weak var modeLabel: NSTextField!
  
  var currentMode: VimMode = .normal
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    sourceTextView.vimDelegate = self
    
    
    // Do any additional setup after loading the view.
  }

  override var representedObject: AnyObject? {
    didSet {
    // Update the view, if already loaded.
    }
  }
  
  func modeDidChange(to mode: VimMode) {
    
    modeLabel.stringValue = mode.rawValue.uppercased()
  }
}
