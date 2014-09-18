//
//  Network.swift
//  Network
//
//  Created by Remi Robert on 18/09/14.
//  Copyright (c) 2014 remirobert. All rights reserved.
//

import UIKit

extension NSData {
    func convertToJson() -> String {
        return NSString(bytes: self.bytes, length: self.length, encoding: NSUTF8StringEncoding)
    }
}

class CrackersDelegate :NSObject, NSURLConnectionDataDelegate {
    var crackersDelegatedidFailWithError: (error: NSError) -> ()
    var crackersDelegateconnectionDidFinishLoading: (receivedData: NSData?, response: NSURLResponse?) -> ()
    var crackersReceiveData: NSMutableData?
    var crackersResponseRequest: NSURLResponse?
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.crackersDelegatedidFailWithError(error: error)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        self.crackersDelegateconnectionDidFinishLoading(receivedData: self.crackersReceiveData, response: self.crackersResponseRequest)
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.crackersResponseRequest = response
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.crackersReceiveData?.appendData(data)
    }
    
    init(error :((error:NSError) -> ()),
        finish:((data:NSData?, response:NSURLResponse?) -> ())) {
            self.crackersDelegatedidFailWithError = error
            self.crackersDelegateconnectionDidFinishLoading = finish
            self.crackersReceiveData = NSMutableData()
    }
}

class Crackers {
    let request :NSMutableURLRequest
    
    func setHeader(value: String, headerField: String) {
        self.request.setValue(value, forHTTPHeaderField: headerField)
    }
    
    func setAutorizationHeader(username: String, password :String) {
        let appendedString: String = username + ":" + password
        let encode: NSData = appendedString.dataUsingEncoding(NSUTF8StringEncoding)!
        let encodeAutorization: String = encode.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
        self.request.setValue("Basic " + encodeAutorization, forHTTPHeaderField: "Authorization")
    }

    func setParameters(parameters: NSDictionary?) {
        if (parameters != nil) {
            var jsonData: NSData? = NSJSONSerialization.dataWithJSONObject(parameters!, options: NSJSONWritingOptions.allZeros, error: nil)
            self.request.HTTPBody = jsonData
        }
    }

    private func makeRequest(httpMethod: String, completion:(data: NSData?, response: NSURLResponse?, error: NSError?) -> ()) {
        self.request.HTTPMethod = httpMethod
        var connexion :NSURLConnection = NSURLConnection(request: self.request, delegate: CrackersDelegate(error: { (error) -> () in
            completion(data: nil, response: nil, error: error)
            }, finish: { (data, response) -> () in
                completion(data: data, response: response, error: nil)
        }))
        connexion.start()
    }

    func requestPOST(completion: (data: NSData?, response: NSURLResponse?, error: NSError?) -> ()) {
        self.makeRequest("POST", completion)
    }
    
    func requestGET(completion: (data: NSData?, response: NSURLResponse?, error: NSError?) -> ()) {
        self.makeRequest("GET", completion)
    }
    
    func requestPUT(completion: (data: NSData?, response: NSURLResponse?, error: NSError?) -> ()) {
        self.makeRequest("PUT", completion)
    }

    func requestDELETE(completion: (data: NSData?, response: NSURLResponse?, error: NSError?) -> ()) {
        self.makeRequest("DELETE", completion)
    }
    
    init() {
        self.request = NSMutableURLRequest()
        self.request.timeoutInterval = 60
    }
    
    init(url: String) {
        self.request = NSMutableURLRequest(URL: NSURL(string: url))
        self.request.timeoutInterval = 60
    }
}
