//
//  ContentsConst.swift
//  KidsFab
//
//  Created by 会津慎弥 on 2017/11/19.
//  Copyright © 2017年 会津慎弥. All rights reserved.
//

import UIKit

enum GraphicType: Int {
    case circle = 1
    case rectangle = 2
    case square = 3
}

enum Category: Int {
    case character = 0
    case plant
    case eat
    case human
    case animal
    case car
    case mark
    case etc
    
    func getImage() -> UIImage {
        switch self {
        case .character:
            return UIImage(named: "character.png")!
        case .plant:
            return UIImage(named: "plant.png")!
        case .eat:
            return UIImage(named: "eat.png")!
        case .human:
            return UIImage(named: "human.png")!
        case .animal:
            return UIImage(named: "animal.png")!
        case .car:
            return UIImage(named: "car.png")!
        case .mark:
            return UIImage(named: "mark.png")!
        case .etc:
            return UIImage(named: "etc.png")!
        }
    }
    
    func getName() -> String {
        switch self {
        case .character:
            return "キャラクター"
        case .plant:
            return "しょくぶつ"
        case .eat:
            return "たべもの"
        case .human:
            return "じんぶつ"
        case .animal:
            return "どうぶつ"
        case .car:
            return "のりもの"
        case .mark:
            return "マーク"
        case .etc:
            return "そのた"
        }
    }
}
