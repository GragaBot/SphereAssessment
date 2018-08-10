//
//  CommentAPI.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/7/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation

class CommentAPI : NSObject {
    
    var commentRef = API().commentRef
    var postRef = API().postRef
    
    // Observe comments with ID
    
    func fetchComment(withCommentID id:String, completed:@escaping(Comments)->Void ) {
        
        commentRef.child(id).observeSingleEvent(of: .value, with: {
            snapshot in
            
            guard let comment = snapshot.value as? [String:Any] else {
                print("Fetch comments fails")
                return
            }
            
            let newComment = Comments.initWithCommentID(commentID: id, contents: comment)
            completed(newComment!)
            
        })
    }
    
    
    // Get Comments from a post
    
    func fetchComments(fromPostID postID:String,withLimitToLast number:UInt, completed:@escaping([Comments]?)->Void) {
        
        let commentRef = postRef.child(postID).child("comments")
        var tempComments = [Comments]()
        
        API.postAPI.fetchPostCommentsCount(withID: postID, completion: {
            count in
            
            guard count > 0 else {
                completed(nil)
                return
            }
            
            var actualCount : UInt
            if count < number {
                actualCount = count
            }
            else {
                actualCount = number
            }
            commentRef.queryOrderedByKey().queryLimited(toLast: actualCount).observe(.childAdded, with: {
                snapshot in
                
                guard (snapshot.value as? Bool) != nil else {
                    completed(nil)
                    commentRef.removeAllObservers()
                    return
                }
                let commentID = snapshot.key
                self.fetchComment(withCommentID: commentID, completed: {
                    Value in
                    tempComments.insert(Value, at: 0)
                    
                    // When finished
                    if tempComments.count == Int(actualCount) {
                        commentRef.removeAllObservers()
                        completed(tempComments)
                    }
                    
                })
            }, withCancel: {
                error in
                print(error.localizedDescription)
                return
            })
        })
        
        
        
    }
    
    // Create Comments for a post
    
    func createComment(forPost postID:String, withCaption caption:String, completed:@escaping()->Void) {
        
        guard let currentUser = Profile.currentUser else {
            return
        }
        let userID = currentUser.userID
        let userName = currentUser.username
        let now = Date().now()
        let autoCommentRef = commentRef.childByAutoId()
        let autoCommentID = autoCommentRef.key
        let newComment = Comments.init(timestamp: now, commentID: nil, creatorID: userID, creator: userName, likedUsers: nil, caption: caption)
        
        // Upload to Comments and Post -> comments
        postRef.child(postID).child("comments").child(autoCommentID).setValue(true)
        commentRef.child(autoCommentID).setValue(newComment.dictValue(), withCompletionBlock: {
            error, _ in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            completed()
            
        })
        
        
    }
    
}
