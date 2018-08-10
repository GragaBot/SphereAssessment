//
//  ProfileStruct.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 3/14/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import SVProgressHUD

class Profile {
    let userID:String
    var email:String
    var username:String
    var tickets:Int
    var checkInCount:Int
    var lastCheckDate:String
    var followers:[String]?
    var following:[String]?
    var followBrands:[String]?
    var posts:[String]?
    var profilePicUrl:URL?
    var backgroundPictureUrl: URL?
    var bio: String?
    var website: String?
    var editor:Bool
    static var currentUser:Profile?
    
    init(username:String, email:String,userID:String, tickets: Int, followers:[String]?, following:[String]?,followBrands:[String]?,checkInCount: Int, posts:[String]?, profilePicUrl:URL?, backgroundPictureUrl: URL?, bio: String?, website: String?) {
        self.username = username
        self.userID = userID
        self.email = email
        self.tickets = tickets
        self.followers = followers
        self.following = following
        self.followBrands = followBrands
        self.checkInCount = checkInCount
        self.posts = posts
        self.profilePicUrl = profilePicUrl
        self.backgroundPictureUrl = backgroundPictureUrl
        self.bio = bio
        self.website = website
        lastCheckDate = Date().now()
        editor = false
        // Check in upon login
        //It's the local time, later it should be a world time and can't be changed from the user's calendar
    }
    // Used during register
    static func newUser(username:String!,userID:String!, email:String!) -> Profile {
        return Profile(username: username, email:email, userID: userID, tickets:0, followers: [String](), following: [String](), followBrands:[String](),checkInCount:1,posts: [String](), profilePicUrl: nil, backgroundPictureUrl: nil, bio: nil, website: nil)
    }
    
    // Used during login
    static func initWithUserID(userID:String , profileDict: [String:Any]) -> Profile? {
        let profile = Profile.newUser(username: "Default", userID: userID, email: "Default")
        if let lastCheckDate = profileDict["lastCheckDate"] as? String {
            profile.lastCheckDate = lastCheckDate
        }
        //fetch username,email,raffleTickets,checkinCount,followers,followings, brands,posts, picture
        var followerStr = [String]()
        var followingStr = [String]()
        var postStr = [String]()
        
        if let email = profileDict["email"] as? String {
            profile.email = email
        }
        if let username = profileDict["username"] as? String {
            profile.username = username
        }
        if let tickets = profileDict["tickets"] as? Int {
            profile.tickets = tickets
        }
        if let checkInCount = profileDict["checkInCount"] as? Int {
            profile.checkInCount = checkInCount
        }
        if let followers = profileDict["followers"] as? [String:Bool] {
            for tempfollowers in followers {
                followerStr.append(tempfollowers.key)
            }
            profile.followers = followerStr
        }
        if let following = profileDict["following"] as? [String:Bool] {
            for tempfollowing in following {
                followingStr.append(tempfollowing.key)
            }
            profile.following = followingStr
        }
        if let brands = profileDict["followBrands"] as? [String] {
            profile.followBrands = brands
        }
        if let imgUrlString = profileDict["profilePicUrl"] as? String {
            profile.profilePicUrl = URL(string: imgUrlString)
        }
        
        if let bgimgUrlString = profileDict["backgroundPictureUrl"] as? String {
            profile.backgroundPictureUrl = URL(string:bgimgUrlString)
        }
        if let bio = profileDict["bio"] as? String{
            profile.bio = bio
        }
        if let website = profileDict["website"] as? String{
            profile.website = website
        }
        if profileDict["editor"] != nil {
            profile.editor = true
        }
        else {
            profile.editor = false
        }

        if let posts = profileDict["posts"] as? [String:Bool] {
            for some in posts {
                postStr.append(some.key)
            }
            profile.posts = postStr
        }
        
        return profile
    }
    // put all info into dict
    func dictValue() -> [String:Any] {
        
        var profileDict:[String:Any] = [:]
        //fetch userID,username,email,tickets,checkInCount,followers,following, followBrands,posts, picture
        var followerDB = [String:Bool]()
        var followingDB = [String:Bool]()
        var postDB = [String:Bool]()
        
        //profileDict["userID"] = userID
        profileDict["username"] = username
        profileDict["email"] = email
        profileDict["tickets"] = tickets
        profileDict["checkInCount"] = checkInCount
        profileDict["followBrands"] = followBrands
        if let postnew = posts {
            for postStr in postnew {
                postDB[postStr] = true
                
            }
            profileDict["posts"] = postDB
        }
        if let followersnew = followers {
            for followerStr in followersnew {
                followerDB[followerStr] = true
            }
            profileDict["followers"] = followerDB
        }
        if let followingnew = following {
            for followingStr in followingnew {
                followingDB[followingStr] = true
            }
            profileDict["following"] = followingDB
        }

        profileDict["lastCheckDate"] = lastCheckDate
        profileDict["bio"] = bio
        profileDict["website"] = website
        if editor == true {
            profileDict["editor"] = "yes"
        }
        if let profilepicurl = profilePicUrl {
            profileDict["profilePicUrl"] = "\(profilepicurl)"
        }
        if let backgroundpiculr = backgroundPictureUrl {
            profileDict["backgroundPictureUrl"] = "\(backgroundpiculr)"
        }
        return profileDict
    }
    //sync the user profile to database
    func sync(onSuccess: @escaping ()->Void, onError: @escaping (Error)->Void) {
        
        API.userAPI.uploadToDatabase(withID: userID, dictValue: dictValue(), onSuccess: onSuccess, onError: {
            error in
            onError(error)
        })

    }
}

