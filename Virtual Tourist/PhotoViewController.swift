//
//  PhotoViewController.swift
//  Virtual Tourist
//
//  Created by Marcus Ronélius on 2015-12-30.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    var pin: Pin!
    var photo: Photo!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        self.imageView.image = photo.image
    }
    
    @IBAction func deletePhoto(sender: AnyObject) {
        self.pin.deletePhoto(photo)
        CoreDataStackManager.sharedInstance().saveContext()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
