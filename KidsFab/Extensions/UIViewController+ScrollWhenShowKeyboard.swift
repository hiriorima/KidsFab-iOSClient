//
//  UIViewController+ScrollWhenShowKeyboard.swift
//  https://gist.github.com/gamako/6f7df33badaf279cc313cb934728a792#file-uiviewcontroller-scrollwhenshowkeyboard-swift-L31
//

import UIKit
import RxSwift
import RxCocoa

extension UIViewController {
    
    // キーボードが現れたときに、テキストフィールドをスクロールする
    func scrollWhenShowKeyboard() {
        
        var disposeBag: DisposeBag? = DisposeBag()
        
        // この関数内で完結するように、dealloc時にdisposeしてくれる仕組みを用意する
        rx.deallocating.subscribe(onNext: { disposeBag = nil }).disposed(by: disposeBag!)
        
        // viewAppearの間だけUIKeyboardが発行するNotificationを受け取るObserbaleを作る
        viewAppearedObservable().flatMapLatest { (b) -> Observable<(Bool, Notification)> in
                if b {
                    // notificationは、(true=表示/false=非表示, NSNotification)のタプルで次のObservableに渡す
                    return Observable.of(
                        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow).map { (true, $0)},
                        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide).map { (false, $0)}
                        ).merge()
                } else {
                    return Observable<(Bool, Notification)>.empty()
                }
            }
            .subscribe(onNext: { [weak self] (a: (isShow: Bool, notification: Notification)) in
                // notificationに対して、適切にスクロールする処理
                if a.isShow {
                    self?.scrollTextFieldWhehKeybordShown(notification: a.notification as NSNotification)
                } else {
                    self?.restoreScrollTextField(notification: a.notification as NSNotification)
                }
            }).disposed(by: disposeBag!)
    }
    
    // キーボードのframeとUITextFieldの位置を比較して、いい感じにスクロールする処理
    // 表示するターゲットは現在のFirstResponder
    // スクロールするUIScrollViewは、その親をたどって見つけている
    //
    // 参考 : http://qiita.com/ysk_1031/items/3adb1c1bf5678e7e6f98
    private func scrollTextFieldWhehKeybordShown(notification: NSNotification) {
        guard let textField = self.view.currentFirstResponder() as? UIView,
            let scrollView = textField.findSuperView(ofType: UIScrollView.self),
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
            let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
            else { return }
        
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        
        let convertedKeyboardFrame = scrollView.convert(keyboardFrame, from: nil)
        let convertedTextFieldFrame = textField.convert(textField.frame, to: scrollView)
        let offsetY = (convertedTextFieldFrame.maxY - convertedKeyboardFrame.minY) / 3
        if offsetY > 0 {
            
            UIView.animate(withDuration: animationDuration) {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: offsetY, right: 0)
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets
                scrollView.contentOffset = CGPoint(x: 0, y: offsetY)
            }
        }
    }
    
    // スクロールを元に戻す
    private func restoreScrollTextField(notification: NSNotification) {
        guard let textField = self.view.currentFirstResponder() as? UIView,
            let scrollView = textField.findSuperView(ofType: UIScrollView.self)
            else { return }
        
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
}

extension UIView {
    
    // 親ビューをたどってFirstResponderを探す
    func currentFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        
        for view in self.subviews {
            if let responder = view.currentFirstResponder() {
                return responder
            }
        }
        
        return nil
    }
    
    // 現在入力中のUITextFieldやUITextViewのカーソル位置に文字を挿入する
    func insertTextToCurrentField(text: String) {
        guard let field = self.currentFirstResponder() as? UIKeyInput else { return }
        field.insertText(text)
    }
    
    // 任意の型の親ビューを探す
    // 親をたどってScrollViewを探す場合などに使用する
    func findSuperView<T>(ofType: T.Type) -> T? {
        if let s = self.superview {
            switch s {
            case let s as T:
                return s
            default:
                return s.findSuperView(ofType: ofType)
            }
        }
        return nil
    }
    
}

extension UIViewController {
    
    // ViewがdidAppearでtrue, didDisappearでfalseになるobservable
    func viewAppearedObservable() -> Observable<Bool> {
        return Observable.of(
            viewDidAppearTrigger.map { true } ,
            viewDidDisappearTrigger.map { false }
            )
            .merge()
    }
}

// http://blog.sgr-ksmt.org/2016/04/23/viewcontroller_trigger/
extension UIViewController {
    private func trigger(selector: Selector) -> Observable<Void> {
        return rx.sentMessage(selector).map { _ in () }.share(replay: 1)
    }
    
    var viewWillAppearTrigger: Observable<Void> {
        return trigger(selector: #selector(self.viewWillAppear(_:)))
    }
    
    var viewDidAppearTrigger: Observable<Void> {
        return trigger(selector: #selector(self.viewDidAppear(_:)))
    }
    
    var viewWillDisappearTrigger: Observable<Void> {
        return trigger(selector: #selector(self.viewWillDisappear(_:)))
    }
    
    var viewDidDisappearTrigger: Observable<Void> {
        return trigger(selector: #selector(self.viewDidDisappear(_:)))
    }
}
