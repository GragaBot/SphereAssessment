//
//  ProfileCollectionCell.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/20/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation

class ProfileCollectionCell: UICollectionViewCell {
    
    @IBOutlet var profilePostImageView: UIImageView!
    
    @IBOutlet var imageIndicator: UIActivityIndicatorView!
    var postID: String? {
        didSet {
            updateImage()
        }
    }
    
    func updateImage() {
        if let postid = postID {
            imageIndicator.startAnimating()
            API.postAPI.fetchPostImageURL(withPostID: postid, completed: {
                url in
                self.profilePostImageView.setImage(url: url) {
                    _ in
                    self.imageIndicator.stopAnimating()
                }
                
            })
        }
    }
    
}
