//
//  FollowAPI.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/7/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation

class FollowAPI: NSObject {
    
    var userRef = API().userRef
    var feedRef = API().feedRef
    
    // Upon follow, the feed of the current user will append posts from the following user
    
    func followAction(withUserID userID:String, completed:@escaping()->Void) {
        
        guard let currentUser = Profile.currentUser else {
            return
        }
        Profile.currentUser?.following?.append(userID)
        let currentID = currentUser.userID
        userRef.child(userID).child("followers").child(currentID).setValue(true)
        userRef.child(currentID).child("following").child(userID).setValue(true)
        
        API.userAPI.fetchUserPostsID(withUserID: userID, withLimitToLast: nil, completion: {
            ids in
            if let fetchedIds = ids {
                for currentPostId in fetchedIds {
                    self.feedRef.child(currentID).child(currentPostId).setValue(true)
                }
            }
            completed()
        })

    }
    
    func unfollowAction(withUserID userID:String, completed:@escaping()->Void) {
        
        guard let currentUser = Profile.currentUser else {
            return
        }

        let filtered = currentUser.following?.filter({$0 != userID})
        Profile.currentUser?.following = filtered
        let currentID = currentUser.userID
        userRef.child(userID).child("followers").child(currentID).setValue(nil)
        userRef.child(currentID).child("following").child(userID).setValue(nil)
        API.userAPI.fetchUserPostsID(withUserID: userID, withLimitToLast: nil, completion: {
            ids in
            if let fetchedIds = ids {
                for currentPostId in fetchedIds {
                    self.feedRef.child(currentID).child(currentPostId).setValue(nil)
                }
            }
            completed()
        })

    }
    
    // Check following
    func checkIsFollowing(withUserID userID:String, completed:@escaping(Bool)->Void) {
        
        guard let currentID = Profile.currentUser?.userID else {
            return
        }
        userRef.child(currentID).child("following").child(userID).observeSingleEvent(of: .value, with: {
            snapshot in
            if let _ = snapshot.value as? Bool {
                print("Following")
                completed(true)
            }
            else {
                print("Not following")
                completed(false)
            }
        })
        
    }
    
    func checkIsFollowingLoacally(withUserID userID:String) -> Bool? {
        
        guard let currentUser = Profile.currentUser else {
            return nil
        }
        
        let following = currentUser.following
        if following?.filter({$0 == userID}) != nil {
            return true
        }
        else {
            return false
        }
        
    }
    
}
