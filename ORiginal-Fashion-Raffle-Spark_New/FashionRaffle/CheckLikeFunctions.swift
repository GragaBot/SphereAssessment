//
//  CheckLikeFunctions.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 12/11/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SVProgressHUD

class CheckLikeFuncionts : NSObject {
    
    let ref = FIRDatabase.database().reference()

    
    func handlelike(passKey : String, check: Bool){
        var updateitemLike :[String: Any] = [:]
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        let userID = FIRAuth.auth()?.currentUser?.uid
        let now = dateFormat.string(from: Date())
        let child = ref.child(passKey)
        
        if check == false {
            updateitemLike = [userID!: now]
            SVProgressHUD.showSuccess(withStatus: "You've liked this item.")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.2, execute: {
                SVProgressHUD.dismiss()
            })
            child.child("Liked Users").updateChildValues(updateitemLike)
            
        }
        else {
            SVProgressHUD.showSuccess(withStatus: "You've unliked this item.")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.2, execute: {
                SVProgressHUD.dismiss()
            })
            child.child("Liked Users").removeValue()
        }
    }

    override init() {
        super.init()
    }
}
