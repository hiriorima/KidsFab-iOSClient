//
//  AddNewAcountController.swift
//  2D_PaintTool
//
//  Created by 蛯名真紀 on 2015/12/01.
//  Copyright © 2015年 会津慎弥. All rights reserved.
//

import UIKit
import Spring
import RxSwift
import RxCocoa

class AddNewAcountViewController: UIViewController {
    
    @IBOutlet var IDInputField: UITextField!
    @IBOutlet var PWInputField: UITextField!
    @IBOutlet var PWReinputField: UITextField!
    fileprivate var txtActiveField = UITextField()
    @IBOutlet weak var ErrorLabel: UILabel!

    @IBOutlet var AddButton: UIButton!
    var AddFlag = (0, 0)
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollWhenShowKeyboard()
    }
    
    func bind() {
        let idValidation = IDInputField.rx.text
            .map { text -> Bool in
                text!.count >= 3
            }
            .share(replay: 1)
        
        let pwValidation = PWInputField.rx.text
            .map { text -> Bool in
                text!.count >= 4
            }
            .share(replay: 1)
        
        let pwRepeatedValidation = PWReinputField.rx.text
            .map { text -> Bool in
                text!.count >= 4 && text! == self.PWInputField.text!
            }
            .share(replay: 1)
        
        Observable.combineLatest(idValidation, pwValidation, pwRepeatedValidation) {
            $0 && $1 && $2
            }
            .bind(to: AddButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        AddButton.rx.tap
            .subscribe({ [weak self] _ in self?.AddNewAccountActivity() })
            .disposed(by: disposeBag)
        
        tapGesture.rx.event
            .asObservable()
            .subscribe {_ in
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
    
    func AddNewAccountActivity() {
        
        let request: Request = Request()
        let body = ["userid": IDInputField.text!,
                    "password": PWInputField.text!,
                    "password_confirmation": PWReinputField.text!]
        request.post(RequestConst().createUserURI, body: body)
    }
}
