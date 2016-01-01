//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Marcus Ronélius on 2015-12-30.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    // Constants
    struct Constants {
        
        static let ApiKey : String = "abeba7c2eab33018ebfde9d072880620"
        static let BaseURLSecure : String = "https://api.flickr.com/services/rest/"
        
        static let LONG_MIN = -180.0
        static let LONG_MAX = 180.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let BOUNDINGBOX_WIDTH_HALF = 0.1
        static let BOUNDINGBOX_HEIGHT_HALF = 0.1
        
        static let EXTRAS = "url_m"
        static let SAFE_SEARCH = "1"
        static let NO_JSON_CALLBACK = "1"
        static let PER_PAGE = "30"
        static let DATA_FORMAT = "json"
        
    }
    
    // Methods
    struct Methods {
        static let search = "flickr.photos.search"
    }
    
    // Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let Method = "method"
        static let NoJSONCallback = "nojsoncallback"
        static let Page = "page"
        static let PerPage = "per_page"
        static let Bbox = "bbox"
        static let SafeSearch = "safe_search"
        static let Extras = "extras"
        static let Format = "format"
    }
}