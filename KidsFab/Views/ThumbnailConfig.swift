//
//  CategoryConfig.swift
//  2D_PaintTool
//
//  Created by 会津慎弥 on 2015/11/20.
//  Copyright © 2015年 会津慎弥. All rights reserved.
//

import UIKit

class ThumbnailConfig: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var items = [String]()
    var imgs_name = [String]()
    
    init(items: [String], imgs_name: [String]) {
        self.items = items
        self.imgs_name = imgs_name
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CustomThumbnailCell)!
        
        let url = URL(string: items[indexPath.row])
        print(items[indexPath.row])
        let data = try? Data(contentsOf: url!)
        let img = UIImage(data: data!)
        
        cell.thumbnail.image = img
        cell.backgroundColor = UIColor.white
        cell.img_name.text = imgs_name[indexPath.row]
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let url = URL(string: items[indexPath.row])
        let data = try? Data(contentsOf: url!)
        let img = UIImage(data: data!)
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        appDelegate.searchImg = img
        appDelegate.viewController?.viewChange()
    }
}
