//
//  PostStruct.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 3/14/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

class Post {
    let postID:String?
    let creator:String
    let creatorID:String
    
    var timestamp:String
    var likedUsers:[String]?
    var likeCounter:Int?
    var comments:[String]?
    let imageUrl:URL
    let caption:String?
    let brandinfo:[String]?
    //var giveaway: Giveaway?
    
    static var currentPost:Post?
    
    init(postID:String?,creator:String, creatorID: String, imageUrl:URL, caption:String?, brandinfo:[String]?, timestamp: String, comments:[String]?,likedUsers: [String]?, likeCounter: Int?) {
        self.postID = postID
        self.creator = creator
        self.creatorID = creatorID
        self.imageUrl = imageUrl
        self.caption = caption
        self.brandinfo = brandinfo
        self.timestamp = timestamp
        self.likedUsers = likedUsers
        self.likeCounter = likeCounter
        self.comments = comments
    }
    
    static func initWithPostID(postID: String, postDict:[String:Any]) -> Post? {
        guard let creator = postDict["creator"] as? String, let imageUrlStr = postDict["imageUrl"] as? String else {
            print ("No post here!")
            return nil
        }
        let caption = postDict["caption"] as? String
        let timestamp = postDict["timestamp"] as? String
        let brandinfo = postDict["brandinfo"] as? [String]
        let creatorID = postDict["creatorID"] as? String
        
        var likeUsers = [String]()
        if let likedUsers = postDict["likedUsers"] as? [String:Bool] {
            for tempusers in likedUsers {
                likeUsers.append(tempusers.key)
            }
        }
        var commentsID = [String]()
        if let comments = postDict["comments"] as? [String:Bool] {
            for tempcomments in comments {
                commentsID.append(tempcomments.key)
            }
        }
        
        
        let likeCounter = postDict["likeCounter"] as? Int
        let imageUrl = URL(string: imageUrlStr)!

        return Post(postID: postID, creator: creator, creatorID: creatorID!, imageUrl: imageUrl, caption: caption, brandinfo: brandinfo, timestamp: timestamp!, comments: commentsID, likedUsers: likeUsers, likeCounter: likeCounter)

    }
    
    func dictValue() -> [String:Any] {
        var postDict = [String:Any]()
        
        var likeUsersDB = [String:Bool]()
        var commentsDB = [String:Bool]()
        postDict["creator"] = creator
        postDict["creatorID"] = creatorID
        postDict["brandinfo"] = brandinfo
        postDict["imageUrl"] = "\(imageUrl)"
        if let likeUsers = likedUsers {
            for tempUsers in likeUsers{
                likeUsersDB[tempUsers] = true
            }
            postDict["likedUsers"] = likeUsersDB
        }
        if let comment = comments {
            for tempcomment in comment {
                commentsDB[tempcomment] = true
            }
            postDict["comments"] = commentsDB
        }
        
        postDict["likeCounter"] = likeCounter
        postDict["timestamp"] = timestamp
        if let realcaption = caption {
            postDict["caption"] = realcaption
        }
        return postDict
    }
}


class PhotoEdit {
    var photo: UIImage
    static var currentPhoto: PhotoEdit?
    
    init(photo: UIImage) {
        self.photo = photo
    }
}




