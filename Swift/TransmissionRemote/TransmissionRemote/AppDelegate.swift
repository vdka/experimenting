//
//  AppDelegate.swift
//  TransmissionRemote
//
//  Created by Ethan Jackwitz on 2/10/16.
//  Copyright © 2016 Ethan Jackwitz. All rights reserved.
//

import Cocoa
import CoreServices

internal extension Selector {
  
  static let handler = #selector(Magnet.handler(_:withReplyEvent:))
}

class Magnet: NSObject {
  
  static func handler(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
    
    let currentHandler = MagnetHandler.transmission
    
    guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue where urlString.hasPrefix("magnet:?") else { return }
    
    currentHandler.create(uri: urlString)
  }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, URLSessionDelegate, URLSessionTaskDelegate {

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		
		/// Register event handler
		NSAppleEventManager.shared()
      .setEventHandler(self,
                       andSelector: .handler,
                       forEventClass: AEEventClass(kInternetEventClass),
                       andEventID: AEEventID(kAEGetURL))
		
	}
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
		
		//TODO (ethan): failure message!
		guard let response = (task.response as? HTTPURLResponse) else { return } //An error occured OR non HTTP Request was made
		
		print(response.statusCode)
		switch response.statusCode {
		case 409:
			
			//update credentials & resend network request
			let request = task.originalRequest as! NSMutableURLRequest
			guard let sessionId = response.allHeaderFields["X-Transmission-Session-Id"] as? String else { return } //bad creds
			request.addValue(sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
			
			let newTask = session.dataTask(with: request)
			newTask.resume()
			
			// TODO (ethan): nice success message!
//		case 200:
//			NSApplication.sharedApplication().terminate(nil)
			
		default: break
		}
	}
	
	
	func addTorrent(magnetURI: String) {
		
		let session = Foundation.URLSession(configuration: .default(), delegate: self, delegateQueue: nil)
		let url = URL(string: "http://server.ejackwitz.com:9091/transmission/rpc")!
		let request = NSMutableURLRequest(url: url)
		request.httpMethod = "POST"
		
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("Basic YWRtaW46cGFzc3dvcmQ=", forHTTPHeaderField: "Authorization")
		
		let bodyObject = [
			"method": "torrent-add",
			"arguments": ["filename": magnetURI]
		]
		
		request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
		
		let task = session.dataTask(with: request)
		task.resume()
	}
}
