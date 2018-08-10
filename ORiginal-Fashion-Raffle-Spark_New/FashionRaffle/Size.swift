//
//  Size.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 5/22/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation


struct Size {
    
    static var statusBarHeight: CGFloat {
        if UIApplication.shared.isStatusBarHidden {
            return 0
        }
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    static func navigationBarHeight(_ viewController: UIViewController) -> CGFloat {
        return viewController.navigationController?.navigationBar.frame.size.height ?? CGFloat(0)
    }
    
    static func appBarHeight(_ viewController: UIViewController) -> CGFloat {
        return statusBarHeight + navigationBarHeight(viewController)
    }
    
    static func toolbarHeight(_ viewController: UIViewController) -> CGFloat {
        guard let navigationController = viewController.navigationController else {
            return 0
        }
        guard !navigationController.isToolbarHidden else {
            return 0
        }
        return navigationController.toolbar.frame.size.height
    }
    
    static func screenRectWithoutAppBar(_ viewController: UIViewController) -> CGRect {
        let appBarHeight = Size.appBarHeight(viewController)
        let toolbarHeight = Size.toolbarHeight(viewController)
        return CGRect(
            x: 0,
            y: appBarHeight,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height - appBarHeight - toolbarHeight)
    }
}
