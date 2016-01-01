//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Marcus Ronélius on 2015-12-30.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    
    @NSManaged var title: String?
    @NSManaged var imageURL: String?
    @NSManaged var imagePath: String?
    @NSManaged var pin: Pin?
    
    var image: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(getFilename(NSURL(string: imageURL!)!))
        }
        
        set {
            if let imageURL = self.imageURL {
                FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: getFilename(NSURL(string: imageURL)!))
            }
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        title = dictionary["title"] as? String
        imageURL = dictionary["url_m"] as? String
    }
    
    // before delete this entity delete the image in the FS
    override func prepareForDeletion() {
        // Delete file if possible
        if let imageURL = self.imageURL {
            FlickrClient.Caches.imageCache.removeImage(getFilename(NSURL(string: imageURL)!))
        }
    }
    
    func getFilename(photoURL: NSURL) -> String {
        let components = photoURL.pathComponents
        return components!.last!
    }

}
