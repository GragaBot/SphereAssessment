//
//  FeedAPI.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/7/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import FirebaseDatabase


class FeedAPI : NSObject {
    
    var feedRef = API().feedRef
    var postRef = API().postRef
    
    func removeObserverFromFeed() {
        feedRef.removeAllObservers()
    }
    
    func removeObserverFromPosts() {
        postRef.removeAllObservers()
    }
    
    //***********************************************************//
    // Actual Usage Functions. Fetch the personal feeds
    //***********************************************************//
    
    // Get the amount of posts in the feed for a user
    func fetchFeedCount(completed: @escaping(UInt) -> Void){
        guard let currentUser = Profile.currentUser else {
            print("No users")
            return
        }
        let userID = currentUser.userID
        var fetchCount : UInt = 0
        feedRef.child(userID).observeSingleEvent(of: .value, with: {
            snapshot in
            fetchCount = snapshot.childrenCount
            completed(fetchCount)
        })
    }
    
    
    // Fetch feeds from Feeds // Belong to current User
    func fetchFeeds(withLimitToLast number: UInt, completed: @escaping([Post]?) -> Void) {
        
        guard let currentUser = Profile.currentUser else {
            print("No users")
            return
        }
        let userID = currentUser.userID
        
        var tempPosts = [Post]()
        fetchFeedCount(completed: {
            feedCount in
            guard feedCount > 0 else {
                completed(nil)
                return
            }
            var actualCount : UInt
            if feedCount < number {
                actualCount = feedCount
            }
            else {
                actualCount = number
            }

            //var observer: UInt!
            self.feedRef.child(userID).queryOrderedByKey().queryLimited(toLast: actualCount).observe(.childAdded, with: {
                snapshot in
                guard (snapshot.value as? Bool) != nil else {
                    print("Error getting feeds")
                    return
                }
                let postID = snapshot.key
                API.postAPI.fetchPost(withID: postID, completion: {
                    fetchedPost in
                    tempPosts.insert(fetchedPost, at: 0)
                    // When Finished
                    if tempPosts.count == Int(actualCount) {
                        self.removeObserverFromFeed()
                        completed(tempPosts)
                        
                    }
                })
            }, withCancel:{
                error in
                print(error.localizedDescription)
                return
            })
        })
    }
    
    // Returns True if there is new value in the database
    func checkNewPostsInTable(withFirstPostID PostID:String, completed: @escaping (Bool)->Void) {
        
        guard let currentUser = Profile.currentUser else {
            print("No Users")
            return
        }
        let userID = currentUser.userID
        
        feedRef.child(userID).queryLimited(toLast: 1).observeSingleEvent(of: .value, with: {
            snapshot in
            guard let checkPosts = snapshot.value as? [String:Any] else {
                print("Fetch fails")
                return
            }
            for key in checkPosts.keys {
                if key == PostID {
                    print("No new values now")
                    completed(false)
                    return
                }
                else {
                    print("Has new values")
                    completed(true)
                    return
                }
            }
        })
    }
    
    
    //***********************************************************//
    // Used in the whole post feed
    //***********************************************************//
    
    // Get the amount of posts in the feed
    func fetchPostsCount(completed: @escaping (UInt) -> Void) {
        
        var fetchCount : UInt = 0
        postRef.observeSingleEvent(of: .value, with: {
            snapshot in
            fetchCount = snapshot.childrenCount
            completed(fetchCount)
        })
    }
    
    // Get posts given a maximum limit query from newest
    // This will return a reversed array with latest on the top
    func fetchPostFromPosts(withLimitToLast number:UInt, completion: @escaping ([Post]?) -> Void) {
        
        
        var tempPosts = [Post]()
        fetchPostsCount(completed: {
            postCount in
            
            var actualCount : UInt
            if postCount < number {
                actualCount = postCount
            }
            else {
                actualCount = number
            }
            
            self.postRef.queryOrderedByKey().queryLimited(toLast: actualCount).observe(.childAdded, with: {
                snapshot in
                guard (snapshot.value as? [String:Any]) != nil else{
                    print("Error getting Posts")
                    return
                }
                let postID = snapshot.key
                API.postAPI.fetchPost(withID: postID, completion: {
                    fetchedPost in
                    tempPosts.insert(fetchedPost, at: 0)
                    // When fetched all the data
                    if tempPosts.count == Int(actualCount) {
                        self.removeObserverFromPosts()
                        completion(tempPosts)
                    }
                })
            }, withCancel: {
                error in
                print(error.localizedDescription)
                return
            })
        })
        
        
    }
    
}
