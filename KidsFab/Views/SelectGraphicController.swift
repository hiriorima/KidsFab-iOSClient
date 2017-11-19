//
//  SelectGraphic.swift
//  2D_PaintTool
//
//  Created by 蛯名真紀 on 2015/12/01.
//  Copyright © 2015年 会津慎弥. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SelectGraphicController: UIViewController {
    
    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var rectangleButton: UIButton!
    @IBOutlet weak var squareButton: UIButton!
    
    var selectGraphicImage: UIImage?
    weak var appDelegate = (UIApplication.shared.delegate as? AppDelegate)! //AppDelegateのインスタンスを取得
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    func bind() {
        
        circleButton.rx.tap
            .subscribe(onNext: {
                self.appDelegate?.selectGraphic = 1
            }).disposed(by: disposeBag)
        
        rectangleButton.rx.tap
            .subscribe(onNext: {
                self.appDelegate?.selectGraphic = 2
            }).disposed(by: disposeBag)
        
        squareButton.rx.tap
            .subscribe(onNext: {
                self.appDelegate?.selectGraphic = 3
                
            }).disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
