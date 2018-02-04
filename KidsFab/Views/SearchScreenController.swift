//
//  SearchScreenController.swift
//  2D_PaintTool
//
//  Created by 蛯名真紀 on 2015/12/01.
//  Copyright © 2015年 会津慎弥. All rights reserved.
//

import UIKit

class SearchScreenController: UIViewController {
    
    var thumbnailConfig: ThumbnailConfig?
    
    @IBOutlet weak var CategoryButtonCollection: UICollectionView!
    @IBOutlet weak var CategoryThumbnail: UICollectionView!
    
    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var selectCategoryImg: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    
    weak var appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate?.viewController = self
        getCategoryContents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        CategoryThumbnail.dataSource = self.thumbnailConfig
        CategoryThumbnail.delegate = self.thumbnailConfig
        CategoryButtonCollection.dataSource = self
        CategoryButtonCollection.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getCategoryContents() {
        
        let request: Request = Request()
        let uri = RequestConst().getCategoryContentsURI + String((appDelegate?.category)!.rawValue)
        request.get(uri, callBackClosure: self.renderView)
    }
    
    func Reload(category: Category) {
        
        getCategoryContents()
        selectCategoryImg.image = category.getImage()
        categoryName.text = category.getName()
    }
    
    func viewChange() {
        
        let sv = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "selectGraphic")
        sv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
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
}

extension SearchScreenController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryButtonCell", for: indexPath) as? CategoryButtonCell)!
        cell.CategoryButtonImg.image = Category(rawValue: indexPath.row)?.getImage()
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
        
        let category = Category(rawValue: indexPath.row)
        appDelegate?.category = category!
        
        Reload(category: Category(rawValue: indexPath.row)!)
    }
}
