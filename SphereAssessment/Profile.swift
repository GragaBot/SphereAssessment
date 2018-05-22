//
//  Profile.swift
//  SphereAssessment
//
//  Created by T on 5/17/18.
//  Copyright © 2018 T. All rights reserved.
//

import Foundation

struct Profile: Encodable, Decodable {
    let firstname: String!
    let lastname: String!
    let street: String!
    let city: String!
    let state: String!
    let zip: String!
    /*
    init?(json:[String: Any]){
        guard let firstname = json["firstname"] as? String,
            let lastname = json["lastname"] as? String,
            let street = json["street"] as? String,
            let city = json["city"] as? String,
            let state = json["state"] as? String,
            let zip = json["zip"] as? Int
        
            else {
                return nil
        }
        self.firstname = firstname
        self.lastname = lastname
        self.street = street
        self.city = city
        self.state = state
        self.zip = zip
    }*/
}
