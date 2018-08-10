//
//  FIRStorageAPI.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/1/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import Firebase
import SVProgressHUD


class FIRStorageAPI: NSObject {
    
    let storageRef = FIRStorage.storage().reference()
    
    func uploadDataToStorage (data: Data,itemStoragePath: String, contentType: String?, completion: ((FIRStorageMetadata?, Error?) -> Void)?) {

        let metadata = FIRStorageMetadata()
        metadata.contentType = contentType
        
        storageRef.child(itemStoragePath).put(data, metadata: metadata, completion: completion)

        
    }
    // Upload HeadImage with DetailImages

}
