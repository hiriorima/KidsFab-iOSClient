//
//  LoginViewController.swift
//  2D_PaintTool
//
//  Created by 蛯名真紀 on 2015/12/01.
//  Copyright © 2015年 会津慎弥. All rights reserved.
//

import UIKit
import Spring

func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

func >= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}

class LoginViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var IDInputField: UITextField!
    @IBOutlet var PWInputField: UITextField!
    @IBOutlet var sc: UIScrollView!
    @IBOutlet var Error: UILabel!
    
    fileprivate var txtActiveField = UITextField()
    
    @IBOutlet var LoginButton: SpringButton!
    var LoginFlag = (0, 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sc.frame = self.view.frame

        setTextFieldDelegate()
        sc.delegate = self
        
        IDInputField.placeholder = "IDを入力してください(英数字3~10字)"
        PWInputField.placeholder = "パスワードを入力してください(英数字4~8字)"
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
     キーボード以外をタップするとキーボードを閉じる
     */
    @IBAction func TapScreen(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    /*
     キーボード表示時にテキストフィールドと重なっているか調べる
     重なっていたらスクロールする
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setKeyboardNotification()
    }
    
    @IBAction func TapLoginButton(_ sender: AnyObject) {
        let String_ID = IDInputField.text
        let String_PW = PWInputField.text
        
        //エラー処理
        if String_ID!.characters.count >= 3 {
            LoginFlag.0 =  1
        } else {
            LoginFlag.0 = 0
        }
        
        if String_PW?.characters.count >= 4 {
            LoginFlag.1 =  1
        } else {
            LoginFlag.1 = 0
        }
        
        LoginButton.animation = "shake"
        switch LoginFlag {
        case(0, 0):
            Error.text = "IDとパスワードが違います"
            LoginButton.animate()
        case(1, 0):
            Error.text = "パスワードが違います"
            LoginButton.animate()
        case(0, 1):
            Error.text = "IDが違います"
            LoginButton.animate()
        case(1, 1):
            Error.text = ""
            LoginActivity(String_ID!, password: String_PW!)
        default:
            Error.text = "エラーが発生しました。"
        }
    }
    
    /*
     * ログイン処理
     */
    func LoginActivity(_ userid: String, password: String) {
        
        let request: Request = Request()
        
        let body = ["userid": userid,
                    "password": password]
        
        request.post(RequestConst().loginURI, body: body)
        
    }
    
    func ScreenTransition(_ userid: String) {
        //AppDelegateのインスタンスを取得
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)!
        
        //appDelegateの変数を操作
        appDelegate.user_id = userid
        
        let HomeScreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
        
        // アニメーションを設定.
        HomeScreenViewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        // Viewの移動する.
        self.present(HomeScreenViewController, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {

    func setTextFieldDelegate() {
        IDInputField.delegate = self
        PWInputField.delegate = self
    }
    
    /*
     Returnをタップするとキーボードを閉じる
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func handleKeyboardWillShowNotification(_ notification: Notification) {
        
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        let txtLimit = txtActiveField.frame.origin.y + txtActiveField.frame.height + 8.0
        let kbdLimit = myBoundSize.height - (keyboardScreenEndFrame?.size.height)!
        
        if txtLimit >= kbdLimit {
            sc.contentOffset.y = txtLimit - kbdLimit
        }
    }
    
    @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
        sc.contentOffset.y = 0
    }
    
    func setKeyboardNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(LoginViewController.handleKeyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(LoginViewController.handleKeyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /*
     編集開始時の処理
     *パスワード入力方式設定
     *if:テキストフィールドをタップ
     テキストフィールド初期化
     */
    @IBAction func TextFieldEditingDidBegin(_ sender: UITextField) {
        txtActiveField = sender
        if sender == PWInputField {
            sender.isSecureTextEntry = true
        }
    }
    
    /*
     テキストが編集された際に呼ばれる.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var maxLength: Int = 0
        
        // 文字数最大を決める.
        if textField == IDInputField {
            maxLength = 11
        } else if textField == PWInputField {
            maxLength = 9
        }
        
        // 入力済みの文字と入力された文字を合わせて取得.
        let str = textField.text! + string
        
        // 文字数がmaxLength以下ならtrueを返す.
        if str.characters.count < maxLength {
            return true
        }
        
        return false
    }
}
