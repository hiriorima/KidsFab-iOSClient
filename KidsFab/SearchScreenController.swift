//
//  SearchScreenController.swift
//  2D_PaintTool
//
//  Created by 蛯名真紀 on 2015/12/01.
//  Copyright © 2015年 会津慎弥. All rights reserved.
//

import UIKit

class SearchScreenController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var thumbnailConfig: ThumbnailConfig?
    
    @IBOutlet weak var CategoryButtonCollection: UICollectionView!
    @IBOutlet weak var CategoryThumbnail: UICollectionView!
    
    @IBOutlet weak var homeButton: UIButton!
    
    let baseuri = "imgshow?category="
    
    @IBOutlet weak var selectCategoryImg: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    
    let categoryImg =
        ["character.png",
         "plant.png",
         "eat.png",
         "human.png",
         "animal.png",
         "car.png",
         "mark.png",
         "etc.png"]
    
    //AppDelegateのインスタンスを取得
    weak var appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate?.viewController = self
        
        let request: Request = Request()
        let uri = baseuri+(appDelegate?.category_number)!
        request.get(uri, callBackClosure: self.renderView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CategoryThumbnail.dataSource = self.thumbnailConfig
        CategoryThumbnail.delegate = self.thumbnailConfig
        CategoryButtonCollection.dataSource = self
        CategoryButtonCollection.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func Reload(_ categoryImgString: String, categoryString: String) {
        
        let request: Request = Request()
        
        let uri = baseuri+(appDelegate?.category_number)!
        
        request.get(uri, callBackClosure: self.renderView)
        
        // 表示する画像を設定する.
        let img = UIImage(named: categoryImgString)
        selectCategoryImg.image = img
        categoryName.text = categoryString
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryButtonCell", for: indexPath) as? CategoryButtonCell)!
        
        let img = UIImage(named: categoryImg[indexPath.row])
        
        // set Name
        cell.CategoryButtonImg.image = img
        cell.backgroundColor = UIColor.green
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //AppDelegateのインスタンスを取得
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        
        var categoryString: String = ""
        
        switch categoryImg[indexPath.row] {
        case "character.png":
            appDelegate.category_number = "0"
            categoryString = "キャラクター"
        case "plant.png":
            appDelegate.category_number = "1"
            categoryString = "しょくぶつ"
        case "eat.png":
            appDelegate.category_number = "2"
            categoryString = "たべもの"
        case "human.png":
            appDelegate.category_number = "3"
            categoryString = "じんぶつ"
        case "animal.png":
            appDelegate.category_number = "4"
            categoryString = "どうぶつ"
        case "car.png":
            appDelegate.category_number = "5"
            categoryString = "のりもの"
        case "mark.png":
            appDelegate.category_number = "6"
            categoryString = "マーク"
        case "etc.png":
            appDelegate.category_number = "7"
            categoryString = "そのた"
        default:
            break
        }
        
        Reload(categoryImg[indexPath.row], categoryString: categoryString)
    }
    
    func viewChange() {
        let sv = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "selectGraphic")
        
        sv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        // Viewの移動する.
        self.present(sv, animated: true, completion: nil)
        
    }
    
    func renderView(json: NSArray) {
        
        var images_url = [String]()
        var images_name = [String]()
        
        for  i in 0 ..< json.count {
            let dictionary  = json[i] as? NSDictionary
            images_url.append((dictionary?["filedata"] as? String)!)
            images_name.append((dictionary?["title"] as? String)!)
        }
        
        self.thumbnailConfig = ThumbnailConfig(items: images_url, imgs_name: images_name)
        
        DispatchQueue.main.async(execute: {
            self.CategoryThumbnail.reloadData()
            self.CategoryThumbnail.dataSource = self.thumbnailConfig
            self.CategoryThumbnail.delegate = self.thumbnailConfig
        })
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
