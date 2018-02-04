//
//  AppDelegate.swift
//  2D_PaintTool
//
//  Created by 会津慎弥 on 2015/10/30.
//  Copyright © 2015年 会津慎弥. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var selectGraphic: GraphicType = .circle
    var viewController: SearchScreenController?
    
    var user_id = "Guest"
    var images_url: String?
    var category: Category = .character
    var searchImg: UIImage?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
}
