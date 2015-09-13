//
//  HaroldAPI.swift
//  Harold
//
//  Created by Harlan Haskins on 9/13/15.
//  Copyright © 2015 Harlan Haskins. All rights reserved.
//

import Foundation
import Alamofire

struct Credentials {
    static let portKey = "port"
    static let passwordKey = "password"
    static var port: Int? = NSUserDefaults.standardUserDefaults().objectForKey(portKey)?.integerValue {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(port, forKey: portKey)
        }
    }
    static var password: String? = NSUserDefaults.standardUserDefaults().stringForKey(passwordKey) {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(password, forKey: passwordKey)
        }
    }
}

struct Harold {
    let selected: String
    let filenames: [String]
    
    init(filenames: [String], selected: String) {
        self.filenames = filenames
        self.selected = selected
    }
    
    init?(json: [String: AnyObject]) {
        guard let
            files = json["files"] as? [String],
            selected = json["selected"] as? String else {
                return nil
        }
        self.init(filenames: files, selected: selected)
    }
}

enum HaroldError: ErrorType {
    case Server(message: String)
    case URL
    case Serialization
}

class HaroldAPI: Manager {
    static let sharedManager = HaroldAPI()
    
    override func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, encoding: ParameterEncoding = .URL, headers: [String : String]? = nil) -> Request {
        var finalHeaders = headers ?? [String: String]()
        finalHeaders["X-Authorization"] = Credentials.password
        return super.request(method, URLString, parameters: parameters, encoding: encoding, headers: finalHeaders)
    }
    
    private static func url() -> NSURL? {
        guard let port = Credentials.port else { return nil }
        return NSURL(string: "http://shell.csh.rit.edu:\(port)/")
    }
//    private static func base() -> NSURL? {
//        return NSURL(string: "http://shell.csh.rit.edu:1818/")
//    }
    
    static func loadFilenames(completion: (Harold?, ErrorType?) -> ()) {
        guard let url = url() else {
            completion(nil, HaroldError.URL)
            return
        }
        self.sharedManager
            .request(.GET, url)
            .responseJSON { request, response, result in
                switch result {
                case .Failure(let data, let error):
                    if let
                        data = data,
                        json = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String: AnyObject],
                        message = json["error"] as? String {
                        completion(nil, HaroldError.Server(message: message))
                    }
                    completion(nil, error)
                case .Success(let value):
                    guard let
                        value = value as? [String: AnyObject],
                        harold = Harold(json: value) else {
                            completion(nil, HaroldError.Serialization)
                            return
                    }
                    completion(harold, nil)
                }
        }
    }
    
    static func select(name: String, completion: ErrorType? -> ()) {
        guard let url = url() else {
            completion(HaroldError.URL)
            return
        }
        self.sharedManager
            .request(.POST, url.URLByAppendingPathComponent("select"), parameters: ["name": name])
            .responseJSON { request, response, result in
                switch result {
                case .Failure(let data, let error):
                    if let
                        data = data,
                        json = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String: AnyObject],
                        message = json["error"] as? String {
                            completion(HaroldError.Server(message: message))
                    }
                    completion(error)
                case .Success(_):
                    completion(nil)
                }
            }
    }
}