//
//  NewsFeedData.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 11/14/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import UIKit
import EventKit


class NewsFeed {
    // title, subtitle, detailInfo can't be nil
    let newsID:String?
    var timestamp:String
    let releaseDate:String?
    let title:String
    let subtitle:String
    let detailInfo:String
    var headImageUrl:URL?
    var detailImageUrls:[URL]?
    var tags:[String]?
    var likedUsers:[String]?
    var likeCounter:Int?
    
    static var selectedNews:NewsFeed?
    
    init(newsID:String?, timestamp: String,releaseDate: String?, title:String, subtitle:String, detailInfo:String, tags:[String]?, likedUsers:[String]?, likeCounter:Int?, headImageURL: URL?, detailImageURLs: [URL]?) {
        self.newsID = newsID
        self.title = title
        self.subtitle = subtitle
        self.detailInfo = detailInfo
        self.tags = tags
        self.releaseDate = releaseDate
        self.likedUsers = likedUsers
        self.headImageUrl = headImageURL
        self.detailImageUrls = detailImageURLs
        self.timestamp = timestamp
    }
    
    static func createNewFeed(newsID: String?, releaseDate: String?, title: String, subtitle: String, detailInfo: String, tags: [String]?, headImageURL: URL?, detailImageURLs: [URL]?) -> NewsFeed? {
        
        return NewsFeed(newsID: newsID, timestamp: Date().now(), releaseDate: releaseDate, title: title, subtitle: subtitle, detailInfo: detailInfo, tags: tags, likedUsers: nil, likeCounter:0, headImageURL: headImageURL, detailImageURLs: detailImageURLs)
        
    }
    
    // Fetch the News Feed
    static func initWithNewsID(newsID:String, contents:[String:Any]) -> NewsFeed? {
        guard let title = contents["title"] as? String else{
            print("No news fetched")
            return nil
        }
        let subtitle = contents["subtitle"] as? String
        
        let detailInfo = contents["detailInfo"] as? String
        
        let tags = contents["tags"] as? [String]
        
        let headImageURL: URL?
        
        if let headImageUrlstr = contents["headImageUrl"] as? String {
            headImageURL = URL(string: headImageUrlstr)
        }
        else {
            headImageURL = nil
        }
        
        var detailImageURL = [URL]()
        
        if let detailImageUrlstr = contents["detailImageUrls"] as? [String] {
            for url in detailImageUrlstr {
                let tempURL = URL(string: url)
                detailImageURL.append(tempURL!)
            }
        }
        
        let releaseDate = contents["releaseDate"] as? String
        
        var likeUsers = [String]()
        if let likedUsers = contents["likedUsers"] as? [String:Bool] {
            for tempusers in likedUsers {
                likeUsers.append(tempusers.key)
            }
        }
        let likeCounter = contents["likeCounter"] as? Int
        
        let timestamp = contents["timestamp"] as? String
        
        return NewsFeed(newsID: newsID, timestamp: timestamp!, releaseDate: releaseDate, title: title, subtitle: subtitle!, detailInfo: detailInfo!, tags: tags, likedUsers: likeUsers, likeCounter: likeCounter, headImageURL: headImageURL, detailImageURLs: detailImageURL)

    }
    
    func dictValue() -> [String:Any] {
        var newsDict:[String:Any] = [:]
        //newsID, timestamp, title, titleImage, subtitle, detailInfo, imagePool, tags
        //newsDict["newsID"] = newsID
        
        var likeUsersDB = [String:Bool]()
        newsDict["timestamp"] = timestamp
        newsDict["title"] = title
        newsDict["subtitle"] = subtitle
        newsDict["detailInfo"] = detailInfo
        newsDict["tags"] = tags
        if let likeUsers = likedUsers {
            for tempUsers in likeUsers{
                likeUsersDB[tempUsers] = true
            }
            newsDict["likedUsers"] = likeUsersDB
        }
        newsDict["releaseDate"] = releaseDate
        if let headImageurl = headImageUrl {
            newsDict["headImageUrl"] = "\(headImageurl)"
        }
    
        var detailImageURLStr = [String]()
        if let detailImageurls = detailImageUrls {
            for url in detailImageurls {
                detailImageURLStr.append("\(url)")
            }
            newsDict["detailImageUrls"] = detailImageURLStr
        }
        return newsDict
    }
    // Sync to database

}





