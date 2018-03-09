//
//  REST.swift
//  havr
//
//  Created by Lindi on 5/12/17.
//  Copyright © 2017 TENTON LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias ErrorMessage = String

struct ServiceREST {
    @discardableResult static func request(with rest: RequestREST, completion: @escaping ((ResponseREST) -> Void)) -> DataRequest {
        
        return Alamofire.request(rest.getURL(), method: rest.method, parameters: rest.parameters, encoding: rest.encoding, headers: rest.headers)
            .responseJSON(completionHandler: { (responseObject) in
                if responseObject.isUnAuthorized && rest.getURL().absoluteString.contains(Constants.serviceUrl) {
                    AccountManager.delete()
                    UIApplication.topViewController()?.switchWindowRoot(to: .login)
                    return
                }
                
                let responseREST: ResponseREST = ResponseREST(requestREST: rest, responseData: responseObject.result.value, responseHttp: responseObject.response, error: responseObject.error, data: responseObject.data)
                console("------------------------------------\nRequest: \(rest.description) \nParameters: \(rest.parameters ?? [:])")
                console("Response: \(responseObject.response?.statusCode.description ?? "UNK") \(responseObject.request?.debugDescription ?? "")\nTime: \(responseObject.timeline.totalDuration)")
                completion(responseREST)
            })
    }
}

//MARK - Request Rest
struct RequestREST {
    var baseUrl = Constants.serviceUrl
    fileprivate var requestPath : String
    
    fileprivate var method: HTTPMethod
    var parameters: Parameters?
    var headers: HTTPHeaders = HTTPHeaders()
    var encoding: ParameterEncoding = URLEncoding.default
    
    init(resource: String, method: HTTPMethod = .get, parameters: Parameters? = nil, headers: HTTPHeaders? = nil) {
        self.requestPath = resource.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        self.method = method
        if let headers = headers{
            self.headers = headers
        }
        if let token = AccountManager.userToken, !token.isEmpty {
            self.headers["Authorization"] = "token \(token)"
        }
        self.parameters = parameters
        
        if method == .post || method == .put || method == .patch {
            encoding = JSONEncoding.default
        }
    }
    
    init(resource: [Any], method: HTTPMethod = .get, parameters: Parameters? = nil) {
        let s : [String] = resource.map({
            return String(describing: $0)
        })
        
        self.requestPath = s.joined(separator: "/").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!.appending("/")
        
        self.method = method
        
        if AccountManager.isLogged {
            headers = [
                "Authorization" : "token \(AccountManager.userToken ?? "")"
            ]
        }
        
        self.parameters = parameters
        
        if method == .post || method == .put || method == .patch {
            encoding = JSONEncoding.default
        }
    }
    
    func getURL() -> URL {
        if self.requestPath.contains("microsoft.com/bing") {
            return URL(string: self.requestPath)!
        }
        return URL(string: baseUrl.appending(self.requestPath))!
    }
    
    var description: String {
        return method.rawValue + ": " + getURL().absoluteString
    }
}

//MARK - Response Rest
struct ResponseREST {
    var requestREST: RequestREST
    fileprivate var responseData: Any?
    fileprivate var responseHttp : HTTPURLResponse?
    fileprivate var error: Error?
    fileprivate var data: Data?
    
    /// get status code from http request, if no status code 0
    var statusCode : Int {
        if let statusCode = responseHttp?.statusCode {
            return statusCode
        }
        return 0
    }
    
    /// get json data from http response, if no data JSON.null is return
    var json: JSON {
        if let data = responseData {
            return JSON(data)
        }
        return JSON.null
    }
    
    /// returns true if http response status code is between 200 and 299
    var isHttpSuccess: Bool {
        if let response = self.responseHttp?.statusCode {
            return response >= 200 && response <= 299
        }
        
        return false
    }
    
    /// returns true if http response status code is 400
    var isHttpBad: Bool {
        if let response = self.responseHttp?.statusCode {
            return response == 400
        }
        
        return false
    }
    
    /// returns true if http response status code is 401
    var isHttpUnAuthorized: Bool {
        if let response = self.responseHttp?.statusCode {
            return response == 401
        }
        
        return false
    }
    
    /// returns true if http response status code is 500
    var isHttpServerError: Bool {
        if let response = self.responseHttp?.statusCode {
            return response >= 500 && response <= 599
        }
        
        return false
    }
    
    /// returns true if http response status code is 404
    var isHttpNotFound: Bool {
        if let response = self.responseHttp?.statusCode {
            return response == 404
        }
        
        return false
    }
    /// returns true if request fails
    var isError: Bool {
        return self.error != nil
    }
    
    /// returns true if request is successful
    var isSuccess: Bool {
        return !isError
    }
    
    /// returns message from error or tries to find on response for message
    var errorMessage : ErrorMessage? {
        
        if isHttpServerError {
            return "Service is not available at this moment. Please try again later."
        }
        
        if let error = error?.localizedDescription {
            return error
        }
        
        if let message =  json["detail"].string {
            return message
        }
        
        return nil
    }
    
    func hsError(message: String = "") -> HSError{
        let m = errorMessage ?? message
    
        return HSError(message: m, code: 0)
    }
    
}

//MARK - Extension DataResponse
extension DataResponse {
    var json : JSON {
        if let data = self.result.value {
            return JSON(data)
        }
        
        return JSON.null
    }
    
    var isSuccess: Bool {
        if let response = self.response?.statusCode {
            return response >= 200 && response <= 299
        }
        
        return false
    }
    
    var isBad: Bool {
        if let response = self.response?.statusCode {
            return response == 400
        }
        
        return false
    }
    
    var isError: Bool {
        return self.error != nil
    }
    
    var isUnAuthorized: Bool {
        if let response = self.response?.statusCode {
            return response == 401
        }
        
        return false
    }
    
    var errorMessage : String? {
        if let error = self.error?.localizedDescription {
            return error
        }
        
        if let message = json["detail"].string {
            return message
        }
        
        return nil
    }
}

struct HSError {
    var message: ErrorMessage
    var code : Int
    
    var accountNotExists : Bool {
        return code == 4102
    }
    
    var notExits: Bool {
        return code == 4004
    }
    
    var isNetworkError: Bool {
        return true
    }
    
    static func noInternet() -> HSError {
        return HSError(message: "No Internet connection", code: 300)
    }
    
}
