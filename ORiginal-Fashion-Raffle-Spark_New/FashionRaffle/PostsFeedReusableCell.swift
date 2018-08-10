//
//  PostsFeedReusableCell.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/3/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit
import Imaginary

class PostPoolCell: UITableViewCell {
    
    @IBOutlet weak var captionLabel:UILabel!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var viewProfile: UIButton!
    
    @IBOutlet weak var comment: UIButton!
    @IBOutlet weak var like: UIButton!
    var didLike = true

    var homeTableViewController: UITableViewController?
    
    var post: Post? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let currentPost = post {
            let fetchUserID = currentPost.creatorID
            timeStamp.text = currentPost.timestamp
            if let caption = currentPost.caption {
                self.captionLabel.text = caption
            }
            if let likeCount = currentPost.likeCounter {
                
                self.like.setTitle(String(likeCount) , for: .normal)
            }
            
            if let commentCount = currentPost.comments?.count {
                
                self.comment.setTitle(String(commentCount), for: .normal)
            }
            
            self.like.imageView?.contentMode = .scaleAspectFit
            self.comment.imageView?.contentMode = .scaleAspectFit
            API.userAPI.fetchUserProfilePicUrl(withID: fetchUserID, completion: {
                profileurl in
                if let url = profileurl {
                    self.profileImage.setImage(url: url)
                }
                else {
                    self.profileImage.image = UIImage(named: "UserIcon")
                }
            })
            API.userAPI.fetchUserName(withID: fetchUserID, completion: {
                fetchName in
                self.userNameLabel.text = fetchName
                
            })
            self.loadingIndicator.startAnimating()
            imgView.setImage(url: currentPost.imageUrl) {
                _ in
                self.loadingIndicator.stopAnimating()
            }
            
        }
    }

    // View Profile Button
    @IBAction func profileDidTouch(_ sender: Any) {
        

        Config.showPlainLoading(withStatus: nil)
        let userID = post?.creatorID
        let profileViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileCollectionViewController
        profileViewController.isProfilePage = false
        if userID == Profile.currentUser?.userID {
            
            profileViewController.isCurrentUser = true
            profileViewController.selectedUser = Profile.currentUser
            Config.dismissPlainLoading()
            self.homeTableViewController?.navigationController?.pushViewController(profileViewController, animated: true)
        }
        else {
            API.userAPI.fetchUserInfo(withID: userID!, completion: {
                fetchProfile in
                profileViewController.isCurrentUser = false
                profileViewController.selectedUser = fetchProfile!
                
                Config.dismissPlainLoading()
                self.homeTableViewController?.navigationController?.pushViewController(profileViewController, animated: true)
            })
        }
        
        
    }
    
    @IBAction func likeTapped(_ sender: Any) {
        if let currentPost = post {
            print(currentPost.likedUsers!, "TEST")
            if didLike == true {
                currentPost.likedUsers?.append((Profile.currentUser?.userID)!)
                print(currentPost.likedUsers!, "TEST")
                self.like.setImage(#imageLiteral(resourceName: "likeSelected"), for: .normal)
                self.like.imageView?.contentMode = .scaleAspectFit
                didLike = false
            } else {
                if let index = currentPost.likedUsers?.index(of: (Profile.currentUser?.userID)!){
                    currentPost.likedUsers?.remove(at: index)
                    print(currentPost.likedUsers!, "TEST")
                    self.like.setImage(#imageLiteral(resourceName: "like"), for: .normal)
                    self.like.imageView?.contentMode = .scaleAspectFit
                    didLike = true
                }
            }
            if let temp = currentPost.likedUsers?.count{
                let templikeCount = String(temp)
                self.like.setTitle(templikeCount , for: .normal)
                
            }
            
            
            let postRef = API.postAPI.postRef.child(currentPost.postID!)
            postRef.child("likeCounter").setValue(currentPost.likedUsers?.count)
            
            
        }
        

        
    }
    // Comment Button
    @IBAction func commentDidTap(_ sender: Any) {
        print("FUCK")
        let comment = homeTableViewController?.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! CommentViewController
        comment.postId = post?.postID
        print(comment.postId, "FFFFFFFFFFFF")
        homeTableViewController?.navigationController?.pushViewController(comment, animated: true)

        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        captionLabel.text = ""
        userNameLabel.text = ""
    }
    
    
}
