//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Marcus Ronélius on 2015-12-30.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class Pin: NSManagedObject, MKAnnotation {
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var locationName: String
    @NSManaged var photos: [Photo]?
    @NSManaged var totalPages: NSNumber?
    
    var title: String? = "Location"
    var subtitle: String? = "Show photos from this place"
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
    }
    
    lazy var sharedContext: NSManagedObjectContext! = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    // MKAnnotation
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        willChangeValueForKey("coordinate")
        self.longitude = newCoordinate.longitude
        self.latitude = newCoordinate.latitude
        didChangeValueForKey("coordinate")
        
        willChangeValueForKey("locationName")
        self.setLocationName(coordinate) { (location) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.locationName = location
                self.title = self.locationName
            }
            self.didChangeValueForKey("locationName")
        }
    }
    
    private func setLocationName(location: CLLocationCoordinate2D, completionHandler: (location: String) -> Void) {
        let geoCoder = CLGeocoder()
        let currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // City
            if placeMark != nil {
                if let city = placeMark.addressDictionary!["City"] as? String {
                    print(city)
                    completionHandler(location: city)
                } else {
                    // Country
                    if let country = placeMark.addressDictionary!["Country"] as? String {
                        print(country)
                        completionHandler(location: country)
                    } else {
                        completionHandler(location: "Lat: \(location.latitude) Long: \(location.longitude)")
                    }
                }
            }
        })
    }
    
    func deletePhotos() {
        if let photos = self.photos {
            for photo in photos {
                deletePhoto(photo)
            }
        }
    }
    
    func deletePhoto(photo: Photo) {
        sharedContext.deleteObject(photo)
    }
}
