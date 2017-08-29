//
//  HomeScreenController.swift
//  2D_PaintTool
//
//  Created by 蛯名真紀 on 2015/12/01.
//  Copyright © 2015年 会津慎弥. All rights reserved.
//


import UIKit

class HomeScreenController:UIViewController{
    
    var thumbnailConfig:ThumbnailConfig?
    
    @IBOutlet weak var ThumbnailCollection: UICollectionView!
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet var user: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //AppDelegateのインスタンスを取得
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        username.text = appDelegate.user_id!
        let Guest:UIImage = UIImage(named: "Guest.png")!
        let Member:UIImage = UIImage(named: "Member.png")!
        if(appDelegate.user_id != "Guest"){
            user.image = Member
        }else{
            user.image = Guest
        }

        let request: Request = Request()
        let uri = "imgshow?category=-1"
        request.get(uri, callBackClosure: self.renderView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ThumbnailCollection.dataSource = self.thumbnailConfig
        ThumbnailCollection.delegate = self.thumbnailConfig
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func renderView(json: NSArray){
        
        var images_url:Array<String> = []
        var images_name:Array<String> = []
        
        for  i in 0 ..< json.count {
            let dictionary  = json[i] as! NSDictionary
            images_url.append(dictionary["filedata"] as! String)
            images_name.append(dictionary["title"] as! String)
        }
        
        self.thumbnailConfig = ThumbnailConfig(items: images_url,imgs_name: images_name)
        ThumbnailCollection.dataSource = self.thumbnailConfig
        ThumbnailCollection.delegate = self.thumbnailConfig
    }
    
}
