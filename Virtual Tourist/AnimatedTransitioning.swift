//
//  AnimatedTransitioning.swift
//  Virtual Tourist
//
//  Created by Marcus Ronélius on 2015-12-30.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import UIKit

class AnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresenting: Bool = false
    
    // required
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        
        return 0.25;
    }
    
    // required
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView: UIView = transitionContext.containerView()!
        
        let fromVC: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! as UIViewController;
        let toVC: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! as UIViewController
        
        let screenRect: CGRect = UIScreen.mainScreen().bounds;
        
        if(self.isPresenting) {
            
            containerView.addSubview(toVC.view)
            
            // start the view off screen bottom
            toVC.view.frame = CGRectMake(0, screenRect.size.height, fromVC.view.frame.size.width,
                fromVC.view.frame.size.height)
            
            UIView.animateWithDuration(0.25,
                animations: {
                    fromVC.view.tintAdjustmentMode = UIViewTintAdjustmentMode.Dimmed;
                    toVC.view.frame = CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)
                    
                }, completion: { (value: Bool) in
                    
                    // need to call this otherwise the app will hang
                    transitionContext.completeTransition(true)
            })
        } else {
            
            // start the view off screen bottom
            let destRect: CGRect = UIScreen.mainScreen().bounds;
            
            UIView.animateWithDuration(0.25,
                animations: {
                    
                    toVC.view.tintAdjustmentMode = UIViewTintAdjustmentMode.Automatic;
                    fromVC.view.frame = CGRectMake(0, screenRect.size.height, toVC.view.frame.size.width, toVC.view.frame.size.height)
                    
                }, completion: { (value: Bool) in
                    
                    fromVC.view.removeFromSuperview()
                    // need to call this otherwise the app will hang
                    transitionContext.completeTransition(true)
            })
            
        }
    }
    
}