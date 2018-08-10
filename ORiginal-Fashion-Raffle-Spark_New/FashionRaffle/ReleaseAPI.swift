//
//  ReleaseAPI.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/1/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ReleaseAPI: NSObject {
    let releaseRef = API().releaseRef
    let storageAPI = API.storageAPI
    // Remove Observers From ReleaseNews
    func removeObserverFromRelease() {
        
        releaseRef.removeAllObservers()
        
    }
    
    // Fetch with news ID
    func fetchNews(withID newsID: String, completed: @escaping(NewsFeed)->Void) {
        releaseRef.child(newsID).observeSingleEvent(of: .value, with: {
            snapshot in
            guard let newsDict = snapshot.value as? [String:Any] else {
                print("Fetch news Fails")
                return
            }
            
            let newNews = NewsFeed.initWithNewsID(newsID: newsID, contents: newsDict)
            completed(newNews!)
        })
    }
    
    
    //*******************************************//
    // Fetch News At once
    //*******************************************//
    
    // Fetch news amount
    func fetchNewsCount(completed: @escaping(UInt) -> Void) {
        var fetchCount : UInt = 0
        releaseRef.observeSingleEvent(of: .value, with: {
            snapshot in
            fetchCount = snapshot.childrenCount
            completed(fetchCount)
        })
    }
    
    
    // Fetch with number limit
    func fetchAllNews(withLimitToLast number:UInt, completed: @escaping([NewsFeed]?) -> Void) {
        
        var tempNews = [NewsFeed]()
        fetchNewsCount(completed: {
            amount in
            
            guard amount > 0 else {
                print("No news Feed")
                completed(nil)
                return
            }
            
            var actualCount : UInt
            if amount < number {
                actualCount = amount
            }
            else {
                actualCount = number
            }
            
            self.releaseRef.queryOrderedByKey().queryLimited(toLast: actualCount).observe(.childAdded, with: {
                snapshot in
                
                guard let fetchDict = snapshot.value as? [String:Any] else {
                    print("Fetch News Error")
                    return
                }
                let newsID = snapshot.key
                let temp = NewsFeed.initWithNewsID(newsID: newsID, contents: fetchDict)
                tempNews.insert(temp!, at: 0)
                if tempNews.count == Int(actualCount) {
                    self.removeObserverFromRelease()
                    completed(tempNews)
                }
                
            }, withCancel: {
                error in
                print(error.localizedDescription)
            })
        })
        
    }
    
    // Check new value in the news feed
    func checkNewNewsInTable(withFirstNewsID newsID:String, completed: @escaping (Bool) -> Void) {
        releaseRef.queryLimited(toLast: 1).observeSingleEvent(of: .value, with: {
            snapshot in
            guard let checkNews = snapshot.value as? [String:Any] else {
                print("Fetch News Fails")
                return
            }
            for key in checkNews.keys {
                if key == newsID {
                    print("No new Value now")
                    completed(false)
                    return
                }
                else {
                    print("Has new values, need to fetch maybe.")
                    completed(true)
                    return
                }
            }
        })
    }
    
    
    
    //*******************************************//
    // Upload news.
    //*******************************************//
    
    // Upload
    func uploadNews(withNewsFeed news:NewsFeed, withHeadImage headImage:UIImage, withDetailImages detailImages:[UIImage]?, onSuccess: @escaping()->Void) {
        
        Config.showLoading(Status: "Uploading...")
        let newFeedRef = releaseRef.childByAutoId()
        let newFeedID = newFeedRef.key
        let itemStorageFolderName = newFeedID
        let headImageData = UIImageJPEGRepresentation(headImage, 0.8)!
        let headStoragePath = "ReleaseNews/\(itemStorageFolderName)/headImage.jpg"
        storageAPI.uploadDataToStorage(data: headImageData, itemStoragePath: headStoragePath, contentType: "image/jpeg", completion: {
            metadata, error in
            
            if error != nil {
                Config.showError(withStatus: error!.localizedDescription)
                return
            }
            let headImageUrl = metadata?.downloadURL()
            news.headImageUrl = headImageUrl
            if (detailImages?.count)! > 0 {
                // Has detailImages
                let imagePool = detailImages!
                for i in 0..<imagePool.count {
                    let currentImage = imagePool[i]
                    let currentData = UIImageJPEGRepresentation(currentImage, 0.8)!
                    let uploadPath = "ReleaseNews/\(itemStorageFolderName)/detailImage \(i+1).jpg"
                    self.storageAPI.uploadDataToStorage(data: currentData, itemStoragePath: uploadPath, contentType: "image/jpeg", completion: {
                        detailMeta, detailError in
                        
                        if detailError != nil {
                            Config.showError(withStatus: detailError!.localizedDescription)
                            return
                        }
                        let detailUrl = detailMeta?.downloadURL()
                        news.detailImageUrls?.append(detailUrl!)
                        // If finished
                        if news.detailImageUrls?.count == imagePool.count {
                            newFeedRef.setValue(news.dictValue(), withCompletionBlock: {
                                error, _ in
                                if error != nil {
                                    print(error!.localizedDescription)
                                    return
                                }
                                Config.dismissLoading(onFinished: {
                                    onSuccess()
                                })
                            })
                        }
                    })
                }
            }
            else {
                // No DetailImage
                newFeedRef.setValue(news.dictValue())
                Config.dismissLoading(onFinished: {
                    onSuccess()
                })
            }
        })
        
    }
    
}
