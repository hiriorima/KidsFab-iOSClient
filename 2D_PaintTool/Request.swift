//
//  Request.swift
//  2D_PaintTool
//
//  Created by 蛯名真紀 on 2015/11/25.
//  Copyright © 2015年 会津慎弥. All rights reserved.
//


import UIKit

class Request {
    let session: URLSession = URLSession.shared
    let nooooUrl = URL(string: "http://paint.fablabhakdoate.org/")
    
    // GET METHOD
    func get(_ url: URL, completionHandler: (Data?, URLResponse?, NSError?) -> Void) {
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
        
        let cookies = HTTPCookieStorage.shared.cookies(for: nooooUrl!)
        let header  = HTTPCookie.requestHeaderFields(with: cookies!)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = header
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
    // POST METHOD
    func post(_ url: URL, body: NSMutableDictionary, completionHandler: (Data?, URLResponse?, NSError?) -> Void) {
        
        let cookies = HTTPCookieStorage.shared.cookies(for: nooooUrl!)
        let header  = HTTPCookie.requestHeaderFields(with: cookies!)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = header
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 2))
        } catch {
            // Error Handling
            print("NSJSONSerialization Error")
            return
        }
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
    // PUT METHOD
    func put(_ url: URL, body: NSMutableDictionary, completionHandler: (Data?, URLResponse?, NSError?) -> Void) {
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
        
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.init(rawValue: 2))
        } catch {
            // Error Handling
            print("NSJSONSerialization Error")
            return
        }
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
    
    // DELETE METHOD
    func delete(_ url: URL, completionHandler: (Data?, URLResponse?, NSError?) -> Void) {
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
        
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }
}
