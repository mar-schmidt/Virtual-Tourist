//
//  TravelLocationsController.swift
//  Virtual Tourist
//
//  Created by Marcus Ronélius on 2015-12-30.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class TravelLocationsController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    var pinInFocus: Pin?
    
    let regionExists = "regionExists"
    let centerLatitude = "centerLatitude"
    let centerLongitude = "centerLongitude"
    let spanLatitudeDelta = "spanLatitudeDelta"
    let spanLongitudeDelta = "spanLongitudeDelta"
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedPinResultsController.performFetch()
        } catch {}
        
        self.mapView.delegate = self
        fetchedPinResultsController.delegate = self
        
        // Load previous map state
        loadSavedMapViewRegion()
        
        // Load saved annotations
        for annotation in fetchedPinResultsController.fetchedObjects as! [Pin] {
            annotation.title = annotation.locationName
        }
        self.mapView.addAnnotations(fetchedPinResultsController.fetchedObjects as! [Pin])
        
        // Enable long press gesture
        let longPress = UILongPressGestureRecognizer(target: self, action: "mark:")
        longPress.minimumPressDuration = 0.3
        mapView.addGestureRecognizer(longPress)
    }
    
    func mark(gestureRecognizer:UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let newCoord:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        switch(gestureRecognizer.state) {
        case .Began:
            var locationDictionary = [String : AnyObject]()
            locationDictionary["latitude"] = newCoord.latitude
            locationDictionary["longitude"] = newCoord.longitude
            self.pinInFocus = Pin(dictionary: locationDictionary, context: self.sharedContext)
            self.pinInFocus!.setCoordinate(newCoord)
            self.mapView.addAnnotation(self.pinInFocus!)
            
        case .Changed:
            self.pinInFocus!.setCoordinate(newCoord)
        case .Ended:

            CoreDataStackManager.sharedInstance().saveContext()
        default:
            return
            
        }
    }
    
    // Core Data Convenience
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // lazy fetchedResultsController property
    lazy var fetchedPinResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    // MKMapViewDelegate
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
            let annotation = view.annotation as! Pin
            controller.pin = annotation
            self.navigationController!.pushViewController(controller, animated: true)
            
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
        didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
            
            if newState == MKAnnotationViewDragState.Ending {
                CoreDataStackManager.sharedInstance().saveContext()
            }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapViewRegion(mapView.region)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.draggable = true
            //pinView!.pinTintColor = MKPinAnnotationView.greenPinColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // NSFetchedResultsControllerDelegate methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            pinInFocus = anObject as? Pin
            switch type {
            case .Insert:
                break
            case .Delete:
                break
            case .Update:
                break
            case .Move:
                pinInFocus?.deletePhotos()
                CoreDataStackManager.sharedInstance().saveContext()
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
    }
    
    // NSUserDefaults
    
    // Saves a region to NSUserDefaults
    func saveMapViewRegion(region: MKCoordinateRegion) {
        let userDetaults = NSUserDefaults.standardUserDefaults()
        
        userDetaults.setDouble(region.center.latitude, forKey: centerLatitude)
        userDetaults.setDouble(region.center.longitude, forKey: centerLongitude)
        userDetaults.setDouble(region.span.latitudeDelta, forKey: spanLatitudeDelta)
        userDetaults.setDouble(region.span.longitudeDelta, forKey: spanLongitudeDelta)
        userDetaults.setBool(true, forKey: regionExists)
    }
    
    
    // Load the saved region if exists in NSUserData
    func loadSavedMapViewRegion() {
        let userDetaults = NSUserDefaults.standardUserDefaults()
        
        let savedRegionExists = userDetaults.boolForKey(regionExists)
        
        if (savedRegionExists) {
            let latitude = userDetaults.doubleForKey(centerLatitude)
            let longitude = userDetaults.doubleForKey(centerLongitude)
            let latitudeDelta = userDetaults.doubleForKey(spanLatitudeDelta)
            let longitudeDelta = userDetaults.doubleForKey(spanLongitudeDelta)
            
            mapView.region.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            mapView.region.span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        }
        
    }
}