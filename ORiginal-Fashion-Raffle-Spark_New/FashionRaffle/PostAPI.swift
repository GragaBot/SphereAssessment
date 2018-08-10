//
//  PostAPI.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/2/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PostAPI: NSObject {
    let postRef = API().postRef
    let userRef = API().userRef
    let feedRef = API().feedRef
    let storageAPI = API.storageAPI
    // Remove Observers From Feed
    func removeObserverFromFeed() {
        
        postRef.removeAllObservers()
        
    }
    //***********************************************************//
    // General Usage Function
    //***********************************************************//
    
    // Fetch a single post with postID
    func fetchPost(withID postID: String, completion: @escaping (Post) -> Void) {
        
        postRef.child(postID).observeSingleEvent(of: .value, with: {
            snapshot in
            
            guard let postDict = snapshot.value as? [String:Any] else{
                print("Fetch post Fails")
                return
            }
            let newPost = Post.initWithPostID(postID: postID, postDict: postDict)
            completion(newPost!)
        })
    }
    
    func fetchPostCommentsCount(withID postID:String, completion: @escaping(UInt) ->Void) {
        postRef.child(postID).child("comments").observeSingleEvent(of: .value, with: {
            snapshot in
            
            let count = snapshot.childrenCount
            completion(count)
        })
    }

    //***********************************************************//
    // Used in profile, not in the feed
    //***********************************************************//
    
    // Get the amount of posts of a user
    func fetchUserPostsCount(fromID userID: String, completed: @escaping (UInt) -> Void){
        
        var fetchCount : UInt = 0
        userRef.child(userID).child("posts").observeSingleEvent(of: .value, with: {
            snapshot in
            fetchCount = snapshot.childrenCount
            completed(fetchCount)
        })
    }
    
    // Get posts from a certain user with a maximum limiter
    // Has the chance to have no post
    func fetchUserPosts(fromID userID: String, withLimitToLast number:UInt, completion: @escaping ([Post]?) -> Void) {
        
        fetchUserPostsCount(fromID: userID, completed: {
            (count) in
            
            guard count > 0 else {
                print("no posts")
                completion(nil)
                return
            }

            var actualcount : UInt
            if count < number {
                actualcount = count
            }
            else {
                actualcount = number
            }
            let personalPostsRef = self.userRef.child(userID).child("posts")
            var tempPosts = [Post]()
            // Continously fetch data while added child.
            personalPostsRef.queryOrderedByKey().queryLimited(toLast: actualcount).observe(.childAdded, with: {
                snapshot in
                
                let postID = snapshot.key
                self.fetchPost(withID: postID, completion: {
                    fetchedPost in
                    tempPosts.insert(fetchedPost, at: 0)
                    // When Finished
                    if tempPosts.count == Int(actualcount) {
                        completion(tempPosts)
                    }
                })
            })
        })
    }
    
    func fetchPostImageURL(withPostID postID: String, completed: @escaping(URL)->Void) {
        
        postRef.child(postID).child("imageUrl").observeSingleEvent(of: .value, with: {
            snapshot in
            if let value = snapshot.value as? String {
                let url = URL(string: value)
                completed(url!)
            }
            
        })
    }


    //***********************************************************//
    // Upload Function
    //***********************************************************//
    
    
    // Upload Posts ( Should include normal posts, giveaways and others.)
    // Should update posts under Users, Feed and Posts.
    func uploadPostImage(withImageData imageData:Data, captions: String?, onSuccess: @escaping() -> Void) {
        guard let currentUser = Profile.currentUser else {
            print("No CurrentUser")
            return
        }
        let userID = currentUser.userID
        Config.showLoading(Status: "Uploading...")
        let creator = Profile.currentUser?.username
        let now = Date().now()
        let autoRef = postRef.childByAutoId()
        let autoPostID = autoRef.key
        let storagePath = "Posts/\(autoPostID)/postPic.jpg"
        
        storageAPI.uploadDataToStorage(data: imageData, itemStoragePath: storagePath, contentType: "image/jpeg", completion: {
            metadata, error in
            if error != nil {
                Config.dismissLoading(onFinished: {
                    Config.showError(withStatus: error!.localizedDescription)
                    return
                })
            }
            let url = metadata?.downloadURL()
            // Do three things: Upload posts dict into Posts, append postID into posts in users, append postID into feed of currentUser
            let newPost = Post.init(postID: nil, creator: creator!, creatorID: userID, imageUrl: url!, caption: captions, brandinfo: nil, timestamp: now, comments: nil, likedUsers: nil, likeCounter: 0)
            // 1
            autoRef.setValue(newPost.dictValue())
            // 2
            Profile.currentUser?.posts?.append(autoPostID)
            Profile.currentUser?.sync(onSuccess: {}, onError: {
                error in
                print(error.localizedDescription)
            })
            // 3
            self.feedRef.child(userID).child(autoPostID).setValue(true, withCompletionBlock: {
                error,_ in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                Config.dismissLoading(onFinished: {
                    onSuccess()
                })
            })
        })
    }
}
