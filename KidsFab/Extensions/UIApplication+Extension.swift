//
//  UIApplication+Extension.swift
//  KidsFab
//
//  Created by 会津慎弥 on 2017/09/27.
//  Copyright © 2017年 会津慎弥. All rights reserved.
//

import UIKit

extension UIApplication {
    var topViewController: UIViewController? {
        guard var topViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
    
    var topNavigationController: UINavigationController? {
        return topViewController as? UINavigationController
    }
}
