//
//  SlideOutAnimation.swift
//  ShopApp
//
//  Created by A'zamjon Abdumuxtorov on 22/03/24.
//

import UIKit

final class SlideOutAnimation: NSObject, UIViewControllerAnimatedTransitioning{
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {return}
        
        let containerView = transitionContext.containerView
        
        let time = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: time) {
            fromView.center.y -= containerView.bounds.size.height
            fromView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } completion: { finished in
            transitionContext.completeTransition(finished)
        }
    }
    
    
    
}
