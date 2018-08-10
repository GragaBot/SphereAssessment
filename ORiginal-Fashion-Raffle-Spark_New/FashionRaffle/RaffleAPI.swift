//
//  RaffleAPI.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/2/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import FirebaseDatabase

class RaffleAPI: NSObject {
    let raffleRef = API().raffleRef
    
    // Remove Observer From Raffles
    func removeObserverFromRaffles() {
        
        raffleRef.removeAllObservers()
        
    }
    
    // Fetch with Raffle ID
    func fetchRaffles(withID raffleID: String, completed: @escaping(RaffleFeed)->Void) {
        raffleRef.child(raffleID).observeSingleEvent(of: .value, with: {
            snapshot in
            guard let raffleDict = snapshot.value as? [String:Any] else {
                print("Fetch Raffles Fails")
                return
            }
            
            let newRaffles = RaffleFeed.initWithRaffleID(raffleID: raffleID, contents: raffleDict)
            completed(newRaffles!)
        })
    }
    
    
    //*******************************************//
    // Fetch Raffles At once
    //*******************************************//
    
    // Fetch raffles amount
    func fetchRafflesCount(completed: @escaping(UInt) -> Void) {
        var fetchCount : UInt = 0
        raffleRef.observeSingleEvent(of: .value, with: {
            snapshot in
            fetchCount = snapshot.childrenCount
            completed(fetchCount)
        })
    }
    
    
    // Fetch with number limit
    func fetchAllRaffles(withLimitToLast number:UInt, completed: @escaping([RaffleFeed]?) -> Void) {
        
        var tempRaffles = [RaffleFeed]()
        fetchRafflesCount(completed: {
            amount in
            
            guard amount > 0 else {
                print("no raffleFeed")
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
            
            self.raffleRef.queryOrderedByKey().queryLimited(toLast: actualCount).observe(.childAdded, with: {
                snapshot in
                
                guard let fetchDict = snapshot.value as? [String:Any] else {
                    print("Fetch Raffles Error")
                    return
                }
                let raffleID = snapshot.key
                let temp = RaffleFeed.initWithRaffleID(raffleID: raffleID, contents: fetchDict)
                tempRaffles.insert(temp!, at: 0)
                if tempRaffles.count == Int(actualCount) {
                    self.removeObserverFromRaffles()
                    completed(tempRaffles)
                }
                
            }, withCancel: {
                error in
                print(error.localizedDescription)
                return
            })
        })
        
    }
    
    // Check new value in the Raffles feed
    func checkNewRafflesInTable(withFirstRaffleID raffleID:String, completed: @escaping (Bool) -> Void) {
        raffleRef.queryLimited(toLast: 1).observeSingleEvent(of: .value, with: {
            snapshot in
            guard let checkRaffles = snapshot.value as? [String:Any] else {
                print("Fetch Raffles Fails")
                return
            }
            for key in checkRaffles.keys {
                if key == raffleID {
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
    
    
}
