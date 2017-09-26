//
//  Request.swift
//  2D_PaintTool
//
//  Created by 蛯名真紀 on 2015/11/25.
//  Copyright © 2015年 会津慎弥. All rights reserved.
//


import UIKit
import Alamofire

class Request {
    let session: URLSession = URLSession.shared
    let nooooUrl = URL(string: "http://paint.fablabhakdoate.org/")
    let baseURL = "http://paint.fablabhakodate.org/"
    
    func get(_ uri: String, callBackClosure:@escaping (NSArray)->Void){
        Alamofire.request(baseURL + uri, headers: self.genHeader("GET")).responseJSON { response in
            switch response.result {
            case .success:
                callBackClosure(response.value as! NSArray)
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    // POST METHOD
    func post(_ uri: String, body: Dictionary<String, Any>) {
        Alamofire.request(baseURL + uri, method: .post, parameters: body, encoding: JSONEncoding.default, headers: genHeader("POST")).responseJSON { response in
            switch response.result {
            case .success:
                //callBackClosure(response.value as! NSArray)
                return
            case .failure(let error):
                print(error)
                return
            }
        }
    }
    
    // PUT METHOD
    func put(_ url: URL, body: NSMutableDictionary, completionHandler: @escaping (Data?, URLResponse?, NSError?) -> Void) {
        var request: URLRequest = URLRequest(url: url)
        
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
        session.dataTask(with: request, completionHandler: completionHandler as! (Data?, URLResponse?, Error?) -> Void).resume()
    }
    
    // DELETE METHOD
    func delete(_ url: URL, completionHandler: @escaping (Data?, URLResponse?, NSError?) -> Void) {
        var request: URLRequest = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        session.dataTask(with: request, completionHandler: completionHandler as! (Data?, URLResponse?, Error?) -> Void).resume()
    }
    
    func genHeader(_ method: String) -> [String:String]{
        let cookies = HTTPCookieStorage.shared.cookies(for: nooooUrl!)
        var headers = HTTPCookie.requestHeaderFields(with: cookies!)
        headers["Accept"] = "application/json"
        if (method != "GET") {
            headers["Content-Type"] = "application/json"
        }
        return headers
    }
}
