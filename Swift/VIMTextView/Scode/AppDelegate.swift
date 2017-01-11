//
//  AppDelegate.swift
//  Scode
//
//  Created by Ethan Jackwitz on 6/16/16.
//  Copyright © 2016 Ethan Jackwitz. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  let responder = VimResponder()
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
}

class VimResponder: NSResponder {

}

