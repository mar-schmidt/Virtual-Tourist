//
//  TransitionDelegate.swift
//  Virtual Tourist
//
//  Created by Marcus Ronélius on 2015-12-30.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import UIKit

class TransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let controller: AnimatedTransitioning = AnimatedTransitioning()
        controller.isPresenting = true;
        return controller;
    }
    
    // optional
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let controller: AnimatedTransitioning = AnimatedTransitioning()
        return controller;
    }
}
