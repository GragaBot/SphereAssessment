//
//  followerVCTableViewCell.swift
//  FashionRaffle
//
//  Created by Mac on 5/26/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var followButton: UIButton!
    @IBOutlet var userNameLabel: UILabel!

    enum FollowButtonState: String {
        case CurrentUser = ""
        case NotFollowing = "Follow"
        case Following = "Following"
    }
    
    
    var selectedUser : Profile? {
        didSet{
            updateCell()
        }
    }
    
    var followbuttonState: FollowButtonState = .CurrentUser {
        willSet(newState) {
            switch newState {
            case .CurrentUser:
                followButton.isHidden = true
            case .NotFollowing:
                followButton.isHidden = false
                followButton.backgroundColor = UIColor(red: 0, green: 134/255, blue: 255/255, alpha: 1)
                followButton.setTitleColor(UIColor.white, for: .normal)
                followButton.layer.borderWidth = 0
            case .Following:
                followButton.isHidden = false
                followButton.backgroundColor = UIColor.white
                followButton.setTitleColor(UIColor.black, for: .normal)
                followButton.layer.borderColor = UIColor.black.cgColor
                followButton.layer.borderWidth = 0.8
            }
            followButton.setTitle(newState.rawValue, for: UIControlState())
        }
    }
    
    func updateCell() {
        if let user = selectedUser {
            guard let currentUser = Profile.currentUser else {
                return
            }
            if user.userID == currentUser.userID {
                followbuttonState = .CurrentUser
            }
            else {
                API.followAPI.checkIsFollowing(withUserID: user.userID, completed: {
                    value in
                    if value {
                        self.followbuttonState = .Following
                    }
                    else {
                        self.followbuttonState = .NotFollowing
                    }
                })
            }
            
            if let url = user.profilePicUrl {
                self.userImageView.setImage(url: url)
            }
            else{
                self.userImageView.image = #imageLiteral(resourceName: "UserIcon")
            }
            userNameLabel.text = user.username
            
        }
    }
    

    
    @IBAction func followButtonDidTap(_ sender: Any) {
        
        if followbuttonState == .NotFollowing {
            API.followAPI.followAction(withUserID: selectedUser!.userID, completed: {
                self.followbuttonState = .Following
                print("Follow Success")
            })
        }
        if followbuttonState == .Following {
            API.followAPI.unfollowAction(withUserID: selectedUser!.userID, completed: {
                self.followbuttonState = .NotFollowing
                print("Unfollowed")
            })
        }
        
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userNameLabel.text = ""
        followbuttonState = .CurrentUser
    }


}
