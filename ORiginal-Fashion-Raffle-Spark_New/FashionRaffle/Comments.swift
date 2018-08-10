//
//  Comments.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/4/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation


class Comments {
    
    var timestamp:String
    let commentID:String?
    let creatorID:String
    let creator:String
    var likedUsers:[String]?
    let caption:String
    
    
    init(timestamp: String, commentID: String?, creatorID: String, creator: String, likedUsers:[String]?, caption: String) {
        
        self.timestamp = timestamp
        self.commentID = commentID
        self.creatorID = creatorID
        self.creator = creator
        self.likedUsers = likedUsers
        self.caption = caption
        
    }
    
    static func createComment(commentID: String?, creator: String, creatorID: String, caption: String) -> Comments? {
        
        return Comments(timestamp: Date().now(), commentID: commentID, creatorID: creatorID, creator: creator, likedUsers: nil, caption: caption)
        
    }
    
    static func initWithCommentID(commentID: String, contents:[String:Any]) -> Comments? {
        
        guard let creatorID = contents["creatorID"] as? String else{
            print("No Comments")
            return nil
        }
        var likeUsers = [String]()
        let caption = contents["caption"] as? String
        let timestamp = contents["timestamp"] as? String
        if let likedUsers = contents["likedUsers"] as? [String:Bool] {
            for tempUsers in likedUsers {
                likeUsers.append(tempUsers.key)
            }
        }
        
        let creator = contents["creator"] as? String
        
        return Comments(timestamp: timestamp!, commentID: commentID, creatorID: creatorID, creator: creator!, likedUsers: likeUsers, caption: caption!)
    
    }
    
    func dictValue() -> [String:Any] {
        var commentDict = [String:Any]()
        var likeUsersDB = [String:Bool]()
        
        commentDict["creator"] = creator
        commentDict["creatorID"] = creatorID
        if let likedusers = likedUsers {
            for tempUser in likedusers {
                likeUsersDB[tempUser] = true
            }
        }
        commentDict["likedUsers"] = likeUsersDB
        commentDict["caption"] = caption
        commentDict["timestamp"] = timestamp
        
        return commentDict
    }
    
}
