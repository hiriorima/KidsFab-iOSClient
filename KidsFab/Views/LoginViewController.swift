//
//  LoginViewController.swift
//  2D_PaintTool
//
//  Created by 蛯名真紀 on 2015/12/01.
//  Copyright © 2015年 会津慎弥. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet var IDInputField: UITextField!
    @IBOutlet var PWInputField: UITextField!
    fileprivate var txtActiveField = UITextField()
    
    @IBOutlet var LoginButton: UIButton!
    var LoginFlag = (0, 0)
    
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
        Observable.combineLatest(IDInputField.rx.text.orEmpty.asObservable(), PWInputField.rx.text.orEmpty.asObservable()) {
            $0.characters.count > 3 && $0.characters.count < 10 && $1.characters.count > 4 && $1.characters.count < 8
            }
            .bind(to: LoginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        PWInputField.rx.controlEvent(.editingDidBegin)
            .asObservable()
            .subscribe({_ in
                self.PWInputField.isSecureTextEntry = true
            })
            .disposed(by: disposeBag)
        
        LoginButton.rx.tap
            .subscribe({ [weak self] _ in self?.LoginActivity() })
            .disposed(by: disposeBag)
        
        tapGesture.rx.event
            .asObservable()
            .subscribe {_ in
                self.view.endEditing(true)
            }
            .disposed(by: disposeBag)
    }
    
    func LoginActivity() {
        let request: Request = Request()
        
        let body = ["userid": IDInputField.text!,
                    "password": PWInputField.text!]
        
        request.post(RequestConst().loginURI, body: body)
    }
    
    func ScreenTransition(_ userid: String) {
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        appDelegate.user_id = userid
        
        let HomeScreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
        
        HomeScreenViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.present(HomeScreenViewController, animated: true, completion: nil)
    }
}
