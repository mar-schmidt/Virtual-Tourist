//
//  PhotoDownloader.swift
//  Virtual Tourist
//
//  Created by Marcus Ronélius on 2015-12-30.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import Foundation
import UIKit

extension FlickrClient {
    func downloadPhoto(photoURL: NSURL, completionHandler: (success: Bool, photo: UIImage, errorString: String?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            if let imageData = NSData(contentsOfURL: photoURL) {
                completionHandler(
                    success: true,
                    photo: UIImage(data: imageData)!,
                    errorString: nil
                )
            } else {
                completionHandler(
                    success: false,
                    photo: UIImage(),
                    errorString: "Image does not exist at \(photoURL)"
                )
            }
        }
    }
}