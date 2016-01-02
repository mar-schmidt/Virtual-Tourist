//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Marcus Ronélius on 2015-12-30.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

extension FlickrClient {
    
    // Core Data Context
    var sharedContext: NSManagedObjectContext{
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // GET Methods
    func getPhotos(pin: Pin, completionHandler: (success: Bool, photos: [[String: AnyObject]]?, totalPhotos: Int, totalPages: Int, errorString: String?) -> Void) {
        
        // Set random page for query
        
        var randomPage = 1
        if let numberOfPages = pin.totalPages {
            let numberOfPagesInt = UInt32(numberOfPages as Int)
            randomPage = Int(arc4random_uniform(numberOfPagesInt))
            
            // Somethings seems to be up with Flickr API. If we're requesting a page above a high number, it seems to be returning the same photos. More info in submit notes. To avoid this, we'll simply generating a pagenumber inside the scope of 200 pages
            if randomPage > 200 {
                randomPage = Int(arc4random_uniform(200))
            }
        }

        print("Random page: \(randomPage)")
        
        // Methods
        let methodArguments = [
            FlickrClient.ParameterKeys.Method: Methods.search,
            FlickrClient.ParameterKeys.Bbox: createBoundingBoxString(pin.latitude, longitude: pin.longitude),
            FlickrClient.ParameterKeys.SafeSearch: Constants.SAFE_SEARCH,
            FlickrClient.ParameterKeys.Extras: Constants.EXTRAS,
            FlickrClient.ParameterKeys.Format: Constants.DATA_FORMAT,
            FlickrClient.ParameterKeys.NoJSONCallback: Constants.NO_JSON_CALLBACK,
            FlickrClient.ParameterKeys.Page: randomPage,
            FlickrClient.ParameterKeys.PerPage: Constants.PER_PAGE
        ]
        
        // GET
        taskForGETMethod("", parameters: methodArguments as! [String : AnyObject]) { data, error in
            if let _ = error {
                completionHandler(
                    success: false,
                    photos: nil,
                    totalPhotos: 0,
                    totalPages: 0,
                    errorString: "Get photos failed."
                )
            } else {
                if let photosDictionary = data!.valueForKey("photos") as? [String:AnyObject] {
                    
                    var totalPhotosVal = 0
                    if let totalPhotos = photosDictionary["total"] as? String {
                        totalPhotosVal = (totalPhotos as NSString).integerValue
                    }
                    
                    var totalPagesVal = 0
                    if let totalPages = photosDictionary["pages"] as? NSNumber {
                        totalPagesVal = Int(totalPages)
                    }
                    
                    // Save and store the number of pages returned for the pin
                    pin.totalPages = totalPagesVal
                    
                    if totalPhotosVal > 0 {
                        if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                            completionHandler(
                                success: true,
                                photos: photosArray,
                                totalPhotos: totalPhotosVal,
                                totalPages: totalPagesVal,
                                errorString: nil
                            )
                            print("Total photos: \(totalPhotosVal) Total pages: \(totalPagesVal)")
                        } else {
                            print("Cannot find key 'photo' in \(photosDictionary)")
                            completionHandler(
                                success: false,
                                photos: nil,
                                totalPhotos: 0,
                                totalPages: 0,
                                errorString: "Cannot find key 'photo'."
                            )
                        }
                    } else {
                        print("No photos found")
                        completionHandler(
                            success: false,
                            photos: nil,
                            totalPhotos: totalPhotosVal,
                            totalPages: totalPagesVal,
                            errorString: "No photos found for this place"
                        )
                    }
                } else {
                    print("Cannot find key 'photos'")
                    completionHandler(
                        success: false,
                        photos: nil,
                        totalPhotos: 0,
                        totalPages: 0,
                        errorString: "Cannot find key 'photos'."
                    )
                }
            }
        }
    }
    
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        let bottom_left_long = max(longitude - Constants.BOUNDINGBOX_WIDTH_HALF, Constants.LONG_MIN)
        let bottom_left_lat = max(latitude - Constants.BOUNDINGBOX_HEIGHT_HALF, Constants.LAT_MIN)
        let top_right_long = min(longitude + Constants.BOUNDINGBOX_WIDTH_HALF, Constants.LONG_MAX)
        let top_right_lat = min(latitude + Constants.BOUNDINGBOX_HEIGHT_HALF, Constants.LAT_MAX)
        
        print("\(bottom_left_long),\(bottom_left_lat),\(top_right_long),\(top_right_lat)")
        return "\(bottom_left_long),\(bottom_left_lat),\(top_right_long),\(top_right_lat)"
    }
}
