//
//  ProfileCollectionHeaderViewController.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/20/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit

class ProfileHeaderView: UICollectionReusableView {
    
    @IBOutlet var headerViewLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var profileBackgroundImageView: UIImageView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var followerButton: UIButton!
    @IBOutlet var followingButton: UIButton!
    @IBOutlet var followButton: UIButton!
    @IBOutlet var bioTextView: UITextView!
    @IBOutlet var changeProfileImageButton: UIButton!
    @IBOutlet var changeBackgroundImageButton: UIButton!
    
    var isCurrentUser = true
    var chooseProfileImage = true
    
    var ferArray = [String]()
    var fingArray = [String]()
    
    var homeViewController: UIViewController?
    
    enum FollowButtonState: String {
        case CurrentUser = ""
        case NotFollowing = "+ Follow"
        case Following = "✓ Following"
    }

    var user: Profile? {
        didSet {
            updateProfileView(currentUser: false)
        }
    }
    
    var followButtonState: FollowButtonState = .CurrentUser {
        willSet(newState) {
            switch newState {
            case .CurrentUser:
                followButton.isHidden = true
            case .NotFollowing:
                followButton.isHidden = false
                followButton.backgroundColor = UIColor.white
                followButton.setTitleColor(UIColor.black, for: .normal)
                followButton.tintColor = UIColor.black
                followButton.layer.borderColor = UIColor.gray.cgColor
                followButton.layer.borderWidth = 0.8
            case .Following:
                //Sky color
                followButton.isHidden = false
                followButton.backgroundColor = UIColor(red: 102/255, green: 204/255, blue: 255/255, alpha: 1)
                followButton.setTitleColor(UIColor.white, for: .normal)
                followButton.layer.borderWidth = 0
            }
            followButton.setTitle(newState.rawValue, for: UIControlState())
        }
    }
    
// Run this for the first time the view is loaded
    func initializeView() {
        
        initializeImageView()
        initializeFollowButton()
        
    }
    
    func initializeImageView() {
        // Run for the first time the view is loaded
        setProfileImageView()
        if let selectedUser = user {
            let defaultProfile = UIImage(named: "UserIcon")
            let defaultBackGround = UIImage(named: "profile2")
            
            if let profileUrl = selectedUser.profilePicUrl {
                self.profileImageView.setImage(url: profileUrl, placeholder: defaultProfile)
            }
            else {
                self.profileBackgroundImageView.image = defaultBackGround
            }
            if let backgroundUrl = selectedUser.backgroundPictureUrl {
                self.profileBackgroundImageView.setImage(url: backgroundUrl)
            }
            else {
                self.profileImageView.image = defaultProfile
            }
        }
        
    }
    
    func initializeFollowButton() {
        if let selectedUser = user {
            if isCurrentUser {
                followButtonState = .CurrentUser
            }
            else {
                
                API.followAPI.checkIsFollowing(withUserID: selectedUser.userID, completed: {
                    value in
                    if value {
                        self.followButtonState = .Following
                    }
                    else {
                        self.followButtonState = .NotFollowing
                    }
                    
                })
            }
        }
    }

    func updateProfileView(currentUser: Bool) {
        
        var selectedUser : Profile
        if currentUser {
            selectedUser = Profile.currentUser!
        }
        else {
            selectedUser = self.user!
        }
        
        if let fers = selectedUser.followers {
            self.ferArray = fers
        }
        else {
            self.followerButton.isUserInteractionEnabled = false
        }
        if let fings = selectedUser.following {
            self.fingArray = fings
        }
        else {
            self.followingButton.isUserInteractionEnabled = false
        }
        followerButton.setTitle("Followers: " + String(self.ferArray.count), for: .normal)
        followingButton.setTitle("Followings: " + String(self.fingArray.count), for: .normal)
        
        var bioTemp : String = ""
        var webTemp : String = ""
        if let bio = selectedUser.bio {
            bioTemp = bio
        }
        if let web = selectedUser.website {
            webTemp = web
        }
        if bioTemp == "" && webTemp == "" {
            self.bioTextView.isHidden = true
        }
        else {
            self.bioTextView.isHidden = false
            self.bioTextView.text = bioTemp + "\n" + webTemp
        }

    }
    
    func setProfileImageView() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.backgroundColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
        
    }
    
    @IBAction func followingDidTap(_ sender: Any) {
        print("Following Tapped")
    }
    @IBAction func followerDidTap(_ sender: Any) {
        print("Follower Tapped")
    }
    @IBAction func followDidTap(_ sender: Any) {
        if let selectUser = user {
            if followButtonState == .NotFollowing {
                API.followAPI.followAction(withUserID: selectUser.userID, completed: {
                    self.followButtonState = .Following
                    return
                })
            }
            if followButtonState == .Following {
                API.followAPI.unfollowAction(withUserID: selectUser.userID, completed: {
                    self.followButtonState = .NotFollowing
                    return
                })
            }
        }
    }
    @IBAction func changeProfileImage(_ sender: Any) {
        guard isCurrentUser else {
            print("Other user Profile")
            return
        }
        chooseProfileImage = true
        presentImagePickerView()
    }
    
    @IBAction func changeBackgroundImage(_ sender: Any) {
        guard isCurrentUser else {
            print("Other user Profile")
            return
        }
        chooseProfileImage = false
        presentImagePickerView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        followButtonState = .CurrentUser
    }
    
}

extension ProfileHeaderView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentImagePickerView() {
        Config.showPlainLoading(withStatus: nil)
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        homeViewController?.present(imagePicker, animated: true, completion: {
            Config.dismissPlainLoading()
        })
    }
    
    func setImage(withImage image: UIImage) {
        if chooseProfileImage {
            self.profileImageView.image = image
        }
        else {
            self.profileBackgroundImageView.image = image
        }
    }
    
    func uploadImage(withImage image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 0.7)!
        if chooseProfileImage {
            API.userAPI.uploadCurrentUserProfileImage(imageData: imageData, onSuccess: {
                print("Upload Success")
            })
        }
        else {
            API.userAPI.uploadCurrentUserBackgroundImage(imageData: imageData, onSuccess: {
                print("Upload Success")
            })
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        if let finalImage = selectedImage {
            self.setImage(withImage: finalImage)
            picker.dismiss(animated: true, completion: {
                self.uploadImage(withImage: finalImage)
            })
        }
        
    }
    
    
}






