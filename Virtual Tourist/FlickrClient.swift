//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Marcus Ronélius on 2015-12-30.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import Foundation

class FlickrClient : NSObject {
    
    // Shared Image Cache
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    var session: NSURLSession
    var photos: [Photo]?
    
    var sessionID : String? = nil
    var userID : String? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // Shared Instance
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    // GET
    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1 Set the parameters */
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        /* 2, 3 Build the URL and configure the request */
        let urlString = Constants.BaseURLSecure + method + FlickrClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4 Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5, 6 Parse the data and use the data (happens in completion handler) */
            if let downloadError = downloadError {
                let encodedError = FlickrClient.errorForData(data, response: response, error: downloadError)
                completionHandler(result: nil, error: encodedError)
            } else {
                FlickrClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }
        
        /* 7 Start the request */
        task.resume()
        
        return task
    }
    
    // Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: See if a status_message is returned, else return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        if data != nil {
            if let _ = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String : AnyObject] {
                return NSError(domain: "Flickr Error", code: 0, userInfo: [NSLocalizedDescriptionKey : "An error occurred"])
            }
        }
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
}
