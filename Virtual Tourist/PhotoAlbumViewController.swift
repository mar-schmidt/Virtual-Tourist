//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Marcus Ronélius on 2015-12-30.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newDownloadButton: UIButton!
    @IBOutlet weak var newDownloadBackground: UIVisualEffectView!
    @IBOutlet weak var noPhotosFoundLabel: UILabel!
    
    var pin: Pin!
    var latitudeDelta: Double = 0.01
    var longitudeDelta: Double = 0.001
    var downloadingCount: Int = 0
    var enableUserInteraction = false
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths : [NSIndexPath]!
    var updatedIndexPaths : [NSIndexPath]!
    
    var transitionController: TransitionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = pin.locationName
        
        fetchedResultsController.delegate = self
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.mapView.delegate = self
        self.mapView.region.center = pin!.coordinate
        self.mapView.region.span = MKCoordinateSpan(latitudeDelta: self.latitudeDelta, longitudeDelta: self.longitudeDelta)
        self.mapView.addAnnotation(pin!)
        
        self.newDownloadButton.hidden = true
        self.newDownloadBackground.hidden = true
        self.enableUserInteraction = false
        
        self.transitionController = TransitionDelegate()

        do {
            try fetchedResultsController.performFetch()
        } catch {}
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            if (photo.image == nil) {
                self.downloadingCount++
            }
        }
        
        if self.downloadingCount == 0 {
            self.enableUserInteraction = true
            self.newDownloadButton.hidden = false
            self.newDownloadBackground.hidden = false
        }
        
        if (pin.photos!.isEmpty) {
            loadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.noPhotosFoundLabel.hidden = true
    }
    
    @IBAction func downloadNewPhotos(sender: AnyObject) {
        for photo in fetchedResultsController.fetchedObjects as! [Photo]{
            FlickrClient.Caches.imageCache.removeImage(NSURL(string: photo.imageURL!)!.lastPathComponent!)
            pin.deletePhoto(photo)
            CoreDataStackManager.sharedInstance().saveContext()
        }
        loadData()
    }
    
    func loadData() {
        self.newDownloadButton.hidden = true
        self.newDownloadBackground.hidden = true
        self.enableUserInteraction = false
        self.downloadingCount = Int(FlickrClient.Constants.PER_PAGE)!
        
        FlickrClient.sharedInstance().getPhotos(pin) { (success, result, totalPhotos, totalPages, errorString) in
            if (success == true) {
                print("\(totalPhotos) photos was found")
                
                // Parse the array of photo dict
                let _ = result!.map() { (dictionary: [String : AnyObject]) -> Photo in
                    let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                    photo.pin = self.pin
                    CoreDataStackManager.sharedInstance().saveContext()
                    
                    return photo
                }
                
                // Reload the collection view on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView.reloadData()
                }
            } else {
                if totalPhotos == 0 {
                    self.noPhotosFoundLabel.hidden = false
                    self.noPhotosFoundLabel.text = errorString
                }
            }
        }
    }
    
    // Configure Cell
    func configureCell(cell: PhotoCollectionViewCell, photo: Photo) {
        var cellImage = UIImage(named: "placeholder")
        
        cell.imageView!.image = nil
        cell.activityIndicator.hidden = true
        
        // Set the Album Image
        if photo.imageURL == nil || photo.imageURL == "" {
            cellImage = UIImage(named: "noimage")
        } else if photo.image != nil {
            cellImage = photo.image
            self.newDownloadButton.hidden = false
            self.newDownloadBackground.hidden = false
            self.enableUserInteraction = true
        } else {
            cell.activityIndicator.hidden = false
            cell.activityIndicator.startAnimating()
            
            FlickrClient.sharedInstance().downloadPhoto(NSURL(string: photo.imageURL!)!) { (success, result, errorString) in
                if (success == true) {
                    // update the model, so that the infrmation gets cashed
                    photo.image = result
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.imageView!.image = result
                        
                        cell.activityIndicator.hidden = true
                        cell.activityIndicator.stopAnimating()
                        
                        self.downloadingCount--
                        if self.downloadingCount == 0 {
                            self.newDownloadButton.hidden = false
                            self.newDownloadBackground.hidden = false
                            self.enableUserInteraction = true
                        }
                    })
                } else {
                    print(errorString)
                }
            }
        }
        
        cell.imageView!.image = cellImage
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        configureCell(cell, photo: photo)
        
        return cell
    }
    
    // UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (self.enableUserInteraction) {
            let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
            
            let photoViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoViewController") as! PhotoViewController
            photoViewController.photo = photo
            photoViewController.pin = self.pin
            
            photoViewController.transitioningDelegate = self.transitionController!
            photoViewController.modalPresentationStyle = .Custom
            
            self.presentViewController(photoViewController, animated: true, completion: nil)
        }
    }
    
    // Fetched Results Controller Delegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths  = [NSIndexPath]()
        updatedIndexPaths  = [NSIndexPath]()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // Perform updates into the collectionView
        collectionView.performBatchUpdates({() -> Void in
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            }, completion: nil)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            switch type {
            case .Insert:
                insertedIndexPaths.append(newIndexPath!)
            case .Delete:
                deletedIndexPaths.append(indexPath!)
            case .Update:
                updatedIndexPaths.append(indexPath!)
            default:
                break
            }
    }
}
