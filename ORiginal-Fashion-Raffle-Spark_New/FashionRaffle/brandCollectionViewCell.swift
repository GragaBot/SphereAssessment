//
//  brandCollectionViewCell.swift
//  FashionRaffle
//
//  Created by Mac on 2017/2/5.
//  Copyright © 2017年 Mac. All rights reserved.
//

import UIKit
import Foundation

class brandCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var brandImage: UIImageView!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    
    
}

class BrandData: NSObject {
    var image: String
    var name: String
    
    init(image:String, name:String){
        self.image = image
        self.name = name
        super.init()
    }
}
