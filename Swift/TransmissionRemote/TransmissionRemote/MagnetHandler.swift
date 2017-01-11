//
//  Transmission.swift
//  TransmissionRemote
//
//  Created by Ethan Jackwitz on 2/11/16.
//  Copyright © 2016 Ethan Jackwitz. All rights reserved.
//

//import Alamofire

//func transmission() {
//		guard let response = (task.response as? NSHTTPURLResponse) else { return } //An error occured OR non HTTP Request was made
//
//		print(response.statusCode)
//		switch response.statusCode {
//		case 409:
//
//			//update credentials & resend network request
//			let request = task.originalRequest as! NSMutableURLRequest
//			guard let sessionId = response.allHeaderFields["X-Transmission-Session-Id"] as? String else { return } //bad creds
//			request.addValue(sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
//
//			let newTask = session.dataTaskWithRequest(request)
//			newTask.resume()
//
//			// TODO (ethan): nice success message!
//		case 200:
//			NSApplication.sharedApplication().terminate(nil)
//
//		default: break
//		}
//}

import Foundation

extension URLRequest {
  
  enum Method: String {
    
    case get
    case put
    case post
    case head
    case trace
    case patch
    case delete
    case connect
    case options
  }
  
  var method: Method? {
    get {
      guard let httpMethod = httpMethod else { return nil }
      return Method(rawValue: httpMethod)
    }
    
    set {
      httpMethod = method?.rawValue.uppercased()
    }
  }
}

struct MagnetHandler {
  
  let url: URL
  
  enum Response: Int {
    case created = 201
    case unauthorized = 409
    case successful = 200
  }
  
  func create(uri: String, completionHandler: ((Data?, URLResponse?, NSError?) -> Void)? = nil) {
    
    guard let url = URL(string: uri) else { return completionHandler(nil, nil, nil) }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.method = .post
    
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
    
    
    
    URLSession.shared().dataTask(with: urlRequest, completionHandler: completionHandler).resume()
  }
  
//  let parse: (Data) -> A?
}

extension MagnetHandler {
  
  init?(_ string: String) {
    
    guard let url = URL(string: string) else { return nil }
    self.url = url
  }
}

extension MagnetHandler {
  
  static var transmission = MagnetHandler("http://home.vdka.me:9091/transmission/rpc")!
}

func transmission(_ magnetURI: String) throws {
  
  let bodyObject = [
    "method": "torrent-add",
    "arguments": ["filename": magnetURI]
  ]
  
  let headers = [
    "Content-Type": "application/json",
    "Authorization": "Basic YWRtaW46cGFzc3dvcmQ="
  ]
  
  
  
//  Alamofire
//    .request(.HEAD, "http://home.ejackwitz.com:9091/transmission/rpc")
//    .response { _, response, _, error in
//      
//      //TODO (ethan): handle
//      guard let statusCode = response?.statusCode where statusCode == 409 else { return }
//      
//      
//      //TODO (ethan): handle
//      guard let sessionId = headers["X-Transmission-Session-Id"] else { return }
//      
//      var headers = headers
//      
//      headers.updateValue(sessionId, forKey: "X-Transmission-Session-Id")
//      
//      Alamofire
//        .request(.POST, "http://home.ejackwitz.com:9091/transmission/rpc", parameters: bodyObject, headers: headers)
//        .response { _, _, _, _ in
//          
//      }
//  }
  
}

//		let session = NSURLSession(configuration: .defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
//		let URL = NSURL(string: "http://server.ejackwitz.com:9091/transmission/rpc")!
//		let request = NSMutableURLRequest(URL: URL)
//		request.HTTPMethod = "POST"
//
//		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//		request.addValue("Basic YWRtaW46cGFzc3dvcmQ=", forHTTPHeaderField: "Authorization")
//
//		let bodyObject = [
//			"method": "torrent-add",
//			"arguments": ["filename": magnetURI]
//		]
//
//		request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(bodyObject, options: [])
//		
//		let task = session.dataTaskWithRequest(request)
//		task.resume()
