//
//  CommentTableViewCell.swift
//
//
//  Created by Mac on 6/8/17.
//
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var viewProfile: UIButton!
    var homeTableViewController: UITableViewController?
    
    var userID: String!
    var comment: Comments? {
        didSet {
            updateView()
        }
    }
    func updateView() {
        if let currentComment = comment {
            let fetchUserID = currentComment.creatorID
            let commentcaption = currentComment.caption
            self.commentLabel.text = commentcaption
            
            API.userAPI.fetchUserProfilePicUrl(withID: fetchUserID, completion: {
                profileurl in
                if let url = profileurl {
                    self.profileImageView.setImage(url: url, placeholder: UIImage(named:"UserIcon"))
                }
                else {
                    self.profileImageView.image = UIImage(named: "UserIcon")
                }
            })
            API.userAPI.fetchUserName(withID: fetchUserID, completion: {
                fetchName in
                self.nameLabel.text = fetchName
                
            })
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
            self.profileImageView.clipsToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func profileDidTouch(_ sender: Any) {
        
        Config.showPlainLoading(withStatus: nil)
        let userID = comment?.creatorID
        print(userID, "userID")
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

   
    
}
