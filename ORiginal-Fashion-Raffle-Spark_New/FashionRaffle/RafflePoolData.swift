//
//  RafflePoolData.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 11/30/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import UIKit


class RaffleFeed {
    let raffleID:String?
    var timestamp:String
    
    /* Draw, Release Info attributes. what do we need?
    let releaseDate:String?
    let tags:[String]?
 */
    var tags:[String]?
    
    let title:String
    let subtitle:String
    let detailInfo:String
    var headImageUrl:URL? //Required
    var detailImageUrls:[URL]? //Not required
    var likedUsers:[String]?
    var likeCounter:Int?
    static var selectedRaffle:RaffleFeed?
    
    init(raffleID:String?, title: String, subtitle: String, detailInfo: String, headImageURL: URL?, detailImageURLs: [URL]?, likedUsers: [String]?, likeCounter: Int?, timestamp: String, tags: [String]?) {
        self.raffleID = raffleID
        self.title = title
        self.subtitle = subtitle
        self.detailInfo = detailInfo
        self.headImageUrl = headImageURL
        self.detailImageUrls = detailImageURLs
        self.likedUsers = likedUsers
        self.likeCounter = likeCounter
        self.timestamp = timestamp
        self.tags = tags
    }
    
    static func createNewRaffle(raffleID: String, title: String, subtitle: String, detailInfo: String, tags: [String]?, headImageUrl: URL?, detailImageUrls: [URL]?) -> RaffleFeed? {
        
        return RaffleFeed(raffleID: raffleID, title: title, subtitle: subtitle, detailInfo: detailInfo, headImageURL: headImageUrl, detailImageURLs: detailImageUrls, likedUsers: nil, likeCounter: 0, timestamp: Date().now(), tags: tags)
    }
    
    static func initWithRaffleID(raffleID:String, contents:[String:Any]) -> RaffleFeed? {
        guard let title = contents["title"] as? String else{
            print("No raffle fetched")
            return nil
        }
        let subtitle = contents["subtitle"] as? String
        let detailInfo = contents["detailInfo"] as? String
        let tags = contents["tags"] as? [String]
        let headImageURL : URL?
        if let headImageStr = contents["headImageUrl"] as? String {
            headImageURL = URL(string: headImageStr)
        }
        else {
            headImageURL = nil
        }
        var detailImageURL = [URL]()
        
        if let detailStrs = contents["detailImageUrls"] as? [String] {
            for url in detailStrs {
                let tempURL = URL(string: url)
                detailImageURL.append(tempURL!)
            }
        }
        
        let timestamp = contents["timestamp"] as? String
        var likeUsers = [String]()
        if let likedUsers = contents["likedUsers"] as? [String:Bool] {
            for tempusers in likedUsers {
                likeUsers.append(tempusers.key)
            }
        }
        let likeCounter = contents["likeCounter"] as? Int
        return RaffleFeed(raffleID: raffleID, title: title, subtitle: subtitle!, detailInfo: detailInfo!, headImageURL: headImageURL, detailImageURLs: detailImageURL, likedUsers: likeUsers, likeCounter: likeCounter, timestamp: timestamp!, tags: tags)
        
    }
    
    func dictValue() -> [String:Any] {
        var raffleDict = [String:Any]()
        var likeUsersDB = [String:Bool]()
        raffleDict["raffleID"] = raffleID
        raffleDict["timestamp"] = timestamp
        raffleDict["tags"] = tags
        raffleDict["title"] = title
        raffleDict["subtitle"] = subtitle
        raffleDict["detailInfo"] = detailInfo
        if let likeUsers = likedUsers {
            for tempUsers in likeUsers{
                likeUsersDB[tempUsers] = true
            }
            raffleDict["likedUsers"] = likeUsersDB
        }

        raffleDict["likeCounter"] = likeCounter
        if let headimageurl = headImageUrl {
            raffleDict["headImageUrl"] = "\(headimageurl)"
        }
        var detailimageStrs = [String]()
        if let detailimageurls = detailImageUrls {
            for url in detailimageurls {
                detailimageStrs.append("\(url)")
            }
            raffleDict["detailImageUrls"] = detailimageStrs
        }
        
        return raffleDict
    }
    
}

