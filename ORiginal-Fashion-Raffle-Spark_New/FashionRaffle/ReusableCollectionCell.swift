//
//  ReusableCollectionCell.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 5/22/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit

class ReusableCollectionCell: UICollectionViewCell, UIScrollViewDelegate {
    
    @IBOutlet var collectionScrollView: UIScrollView!
    
    @IBOutlet var collectionImageView: UIImageView!

    let doubleTap : UITapGestureRecognizer = UITapGestureRecognizer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doubleTap.addTarget(self, action: #selector(didDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        collectionScrollView.removeGestureRecognizer(doubleTap)
        collectionScrollView.addGestureRecognizer(doubleTap)
    }
    
    deinit {
        collectionScrollView.removeGestureRecognizer(doubleTap)
        doubleTap.removeTarget(self, action: #selector(didDoubleTap(_:)))
    }
    
    func didDoubleTap(_ sender: UITapGestureRecognizer) {
        if collectionScrollView.zoomScale < collectionScrollView.maximumZoomScale {
            let center = sender.location(in: self.collectionImageView)
            collectionScrollView.zoom(to: zoomRect(center), animated: true)
        }
        else {
            let defaultScale: CGFloat = 1
            collectionScrollView.setZoomScale(defaultScale, animated: true)
        }
    }
    
    func zoomRect(_ center: CGPoint) -> CGRect {
        var zoomRect :CGRect = CGRect()
        let maxscale = collectionScrollView.maximumZoomScale
        zoomRect.size.height = collectionScrollView.frame.height / maxscale
        zoomRect.size.width = collectionScrollView.frame.width / maxscale
        
        zoomRect.origin.x = center.x - zoomRect.size.width / 2.0
        zoomRect.origin.y = center.y - zoomRect.size.height / 2.0
        
        return zoomRect
    }
    
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return collectionImageView
    }
    
}
