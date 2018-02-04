//
//  PaintController.swift
//  2D_PaintTool
//
//  Created by 蛯名真紀 on 2015/10/30.
//  Copyright © 2015年 会津慎弥. All rights reserved.
//

import UIKit
import ACEDrawingView
import Spring
import Reachability

class PaintController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIToolbarDelegate {
    
    @IBOutlet var drawingView: ACEDrawingView!
    @IBOutlet var MenuList: SpringView!
    @IBOutlet var Logout: UIButton!
    @IBOutlet var User: UIImageView!
    @IBOutlet var Username: UILabel!
    
    @IBOutlet var Ellipse_S: UIButton!
    @IBOutlet var Ellipse_F: UIButton!
    @IBOutlet var Rect_S: UIButton!
    @IBOutlet var Rect_F: UIButton!
    
    @IBOutlet var L_width1: UIButton!
    @IBOutlet var L_width2: UIButton!
    @IBOutlet var L_width3: UIButton!
    
    @IBOutlet var Reset: SpringButton!
    @IBOutlet var UnDo: UIButton!
    @IBOutlet var ReDo: UIButton!
    
    // 保存フラグ
    var SaveFlag = (0, 0)
    
    //Maskイメージ
    var maskImage: UIImage = UIImage(named: "Mask.png")!
    @IBOutlet var SaveView: SpringView!
    let CategoryArray: NSArray = ["キャラクター", "しょくぶつ", "たべもの", "じんぶつ", "どうぶつ", "のりもの", "まーく", "そのた"]
    
    @IBOutlet var Tooltable: UITableView!
    let TImgArray: NSArray = ["Menu.png", "Pen.png", "Line.png", "Ellipse.png", "Rect.png", "Eraser.png", "Text.png"]
    
    //選択領域の概形選択&リセットボタンの画像設定
    weak var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    // 背景色の設定
    let select = UIColor.lightGray
    let clear = UIColor.clear
    
    // 初期設定
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 赤の枠線
        drawingView.layer.borderColor = UIColor.red.cgColor
        drawingView.layer.borderWidth = 4.0
        
        // 図形ボタンの非表示
        Ellipse_S.isHidden = true
        Ellipse_F.isHidden = true
        Rect_S.isHidden = true
        Rect_F.isHidden = true
        
        // メニューリスト&セーブウインドウの非表示
        MenuList.isHidden = true
        SaveView.isHidden = true
        
        //選択中背景の初期設定
        L_width1.backgroundColor = select
        // テーブルのスクロール固定
        Tooltable.isScrollEnabled = false
        
        //保存の初期設定
        TitleField.delegate = self
        let pickerView = UIPickerView()
        pickerView.delegate = self
        CategoryField.inputView = pickerView
        
        myToolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        myToolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        myToolBar.backgroundColor = UIColor.black
        myToolBar.barStyle = UIBarStyle.black
        myToolBar.tintColor = UIColor.white
        
        //ToolBarを閉じるボタンを追加
        let myToolBarButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(PaintController.onClick(_:)))
        myToolBarButton.tag = 1
        myToolBar.items = [myToolBarButton]
        
        //TextFieldをpickerViewとToolVerに関連づけ
        CategoryField.inputAccessoryView = myToolBar
        saveButton.layer.cornerRadius = 8
    }
    
    //画面が表示される直前//
    override func viewWillAppear(_ animated: Bool) {
        
        switch appDelegate?.selectGraphic {
        case .circle?:
            self.drawingView.layer.cornerRadius = 325
            self.drawingView.layer.masksToBounds = true
        case .rectangle?:
            drawingView.frame = CGRect(x: 170, y: 100, width: 700, height: 550)
        case .square?:
            drawingView.frame = CGRect(x: 187, y: 62, width: 650, height: 650)
        default:
            ErrorWindow()
        }
        
        //Userの種類と名前の表示
        Username.text = appDelegate?.user_id
        let Guest = UIImage(named: "Guest.png")!
        let Member = UIImage(named: "Member.png")!
        if appDelegate?.user_id != "Guest" {
            User.image = Member
        } else {
            User.image = Guest
        }
        
        // 検索からの画像ロード
        if appDelegate?.searchImg != nil {
            drawingView.loadImage(appDelegate?.searchImg)
            appDelegate?.searchImg = nil
        }
    }
    
    //エッジからのスワイプメニュー表示の規制
    var SwipeM = 0
    
    @IBAction func MenuBack(_ sender: AnyObject) {
        CollisionDetection(MenuList, ONOFF: true)
        SwipeM = 0
    }
    
    @IBAction func SwipeMenuBack(_ sender: AnyObject) {
        CollisionDetection(MenuList, ONOFF: true)
        SwipeM = 0
    }
    
    @IBAction func SwipeMenu(_ sender: AnyObject) {
        if SwipeM == 0 {
            CollisionDetection(MenuList, ONOFF: false)
            MenuList.animation = "slideRight"
            MenuList.animate()
            SwipeM = 1
        }
    }
    
    // 円(線のみ)
    @IBAction func EllipseStroke(_ sender: AnyObject) {
        drawingView.drawTool = ACEDrawingToolTypeEllipseStroke
        Ellipse_S.isHidden = true
        Ellipse_F.isHidden = true
    }
    
    // 円(塗りつぶし)
    @IBAction func EllipseFill(_ sender: AnyObject) {
        drawingView.drawTool = ACEDrawingToolTypeEllipseFill
        Ellipse_S.isHidden = true
        Ellipse_F.isHidden = true
    }
    
    // 四角(線のみ)
    @IBAction func RectStroke(_ sender: AnyObject) {
        drawingView.drawTool = ACEDrawingToolTypeRectagleStroke
        Rect_S.isHidden = true
        Rect_F.isHidden = true
    }
    
    // 四角(塗りつぶし)
    @IBAction func RectFill(_ sender: AnyObject) {
        drawingView.drawTool = ACEDrawingToolTypeRectagleFill
        Rect_S.isHidden = true
        Rect_F.isHidden = true
        
    }
    
    // 戻る
    @IBAction func UnDo(_ sender: AnyObject) {
        drawingView.undoLatestStep()
        
    }
    
    // 進む
    @IBAction func ReDo(_ sender: AnyObject) {
        drawingView.redoLatestStep()
    }
    
    // 線の太さ
    @IBAction func Width1(_ sender: AnyObject) {
        drawingView.lineWidth = 15.0
        L_width1.backgroundColor = select
        L_width2.backgroundColor = clear
        L_width3.backgroundColor = clear
    }
    
    @IBAction func Width2(_ sender: AnyObject) {
        drawingView.lineWidth = 22.5
        L_width1.backgroundColor = clear
        L_width2.backgroundColor = select
        L_width3.backgroundColor = clear
    }
    
    @IBAction func Width3(_ sender: AnyObject) {
        drawingView.lineWidth = 30.0
        L_width1.backgroundColor = clear
        L_width2.backgroundColor = clear
        L_width3.backgroundColor = select
    }
    
    // 全消し
    @IBAction func Reset(_ sender: AnyObject) {
        
        UIAlertController(title: "Clear", message: "編集したデータを全て削除し、\n白紙に戻しますか?", preferredStyle: .alert)
            .addAction(title: "OK") { _ in
                self.drawingView.clear()
                self.Reset.animation = "flipX"
                self.Reset.animate()
            }
            .addAction(title: "CANCEL", style: .cancel)
            .show()
    }
    
    // ToolTable作成 //
    //Table Viewのセルの数を指定
    func tableView(_ Tooltable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TImgArray.count
    }
    
    //各セルの要素を設定する
    func tableView(_ Tooltable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = Tooltable.dequeueReusableCell(withIdentifier: "TtableCell", for: indexPath)
        
        let Timg = UIImage(named: "\(TImgArray[indexPath.row])")
        // Tag番号 1 で UIImageView インスタンスの生成
        let TimageView = Tooltable.viewWithTag(1) as? UIImageView
        TimageView?.image = Timg
        
        //ToolTableCell選択時のバックカラーの変更
        let cellSelectedBgView = UIView()
        cellSelectedBgView.backgroundColor = select
        cell.selectedBackgroundView = cellSelectedBgView
        
        return cell
    }
    // Tableの機能
    func tableView(_ Tooltable: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            CollisionDetection(MenuList, ONOFF: false)
            MenuList.animation = "slideRight"
            MenuList.animate()
        case 1:
            drawingView.drawTool = ACEDrawingToolTypePen
        case 2:
            drawingView.drawTool = ACEDrawingToolTypeLine
        case 3:
            Ellipse_S.isHidden = false
            Ellipse_F.isHidden = false
        case 4:
            Rect_S.isHidden = false
            Rect_F.isHidden = false
        case 5:
            drawingView.drawTool = ACEDrawingToolTypeEraser
        case 6:
            drawingView.drawTool = ACEDrawingToolTypeDraggableText
        default:
            break
        }
        if indexPath.row != 3 {
            Ellipse_F.isHidden = true
            Ellipse_S.isHidden = true
        }
        if indexPath.row != 4 {
            Rect_F.isHidden = true
            Rect_S.isHidden = true
        }
    }
    
    /*--- MenuList　action ---*/
    // 保存,新規作成,home,新規作成
    
    // 保存  //
    @IBOutlet weak var STitleError: UILabel!
    @IBOutlet weak var SCategoryError: UILabel!
    @IBOutlet weak var TitleField: UITextField!
    @IBOutlet weak var CategoryField: UITextField!
    @IBOutlet var saveButton: SpringButton!
    
    var PostTitle = ""
    var PostCategory = 10
    
    var myToolBar: UIToolbar!
    
    @IBAction func Save(_ sender: AnyObject) {
        showSaveDialog()
    }
    
    func showSaveDialog() {
        MenuList.animation = "fadeOut"
        MenuList.animate()
        CollisionDetection(SaveView, ONOFF: false)
        SaveView.animation = "slideDown"
        SaveView.animate()
        CategoryField.placeholder = "カテゴリを選択してください"
        TitleField.placeholder = "タイトルを入力してください(1~15文字)"
    }
    
    //タイトル入力
    //文字数制限
    func textField(_ TittleField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 文字数最大を決める.
        let maxLength: Int = 15
        // 入力済みの文字と入力された文字を合わせて取得.
        let str = TittleField.text! + string
        // 文字数がmaxLength以下ならtrueを返す.
        if str.count <= maxLength {
            return true
        }
        return false}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //カテゴリ選択
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CategoryArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CategoryArray[row] as? String
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        CategoryField.text = CategoryArray[row] as? String
        PostCategory = row
    }
    @objc func onClick(_ sender: UIBarButtonItem) {
        CategoryField.resignFirstResponder()
    }
    
    @IBAction func SavePost(_ sender: AnyObject) {
        
        PostTitle = TitleField.text!
        let UserID = appDelegate!.user_id
        self.view.endEditing(true)
        
        //エラー処理
        if PostTitle.count != 0 {
            SaveFlag.0 =  1
        }
        
        if PostCategory != 10 {
            SaveFlag.1 =  1
        }
        
        switch SaveFlag {
        case (0, 0):
            STitleError.text = "タイトルが入力されていません。"
            SCategoryError.text = "カテゴリが選択されていません。"
        case(0, 1):
            STitleError.text = "タイトルが入力されていません。"
            SCategoryError.text = ""
            
        case (1, 0):
            STitleError.text = ""
            SCategoryError.text = "カテゴリが選択されていません。"
        case(1, 1):
            STitleError.text = ""
            SCategoryError.text = ""
        default:
            ErrorWindow()
        }
        
        if SaveFlag.1 == 1 && SaveFlag.0 == 1 && drawingView.image != nil {
            
            //概形が円の時はくり抜く
            var PostImg: String
            drawingView.layer.borderWidth = 0.0
            
            switch appDelegate?.selectGraphic {
            case .circle?:
                let CutImg = getMaskedImage(drawingView.image)
                UIGraphicsBeginImageContext(CutImg.size)
                // バッファにcImageを描画。
                CutImg.draw(at: CGPoint(x: 0.0, y: 0.0))
                // バッファからUIImageを生成。
                let nonLayerImage = UIGraphicsGetImageFromCurrentImageContext()
                // バッファを解放。
                UIGraphicsEndImageContext()
                // PNGフォーマットのNSDataをUIImageから作成。
                PostImg = Image2String(nonLayerImage!)!
            case .rectangle?:
                PostImg = Image2String(drawingView.image)!
            case .square?:
                PostImg = Image2String(drawingView.image)!
            default:
                PostImg  = ""
            }
            
            let reachability = Reachability()!
            if reachability.connection != .none {
                //インターネット接続あり
                //送信文
                SavePost(UserID: UserID, Title: PostTitle, Category: PostCategory, IMG: PostImg)
                
                UIAlertController(title: "保存完了", message: "Webページからダウンロードしてご使用ください。", preferredStyle: .alert)
                    .addAction(title: "OK") { _ in
                        self.CollisionDetection(self.SaveView, ONOFF: true)
                    }
                    .addAction(title: "キャンセル", style: .cancel)
                    .show()
                
            } else {
                
                UIAlertController(title: "インターネット接続エラー", message: "Webページからダウンロードしてご使用ください。", preferredStyle: .alert)
                    .addAction(title: "OK")
                    .show()
            }
        } else {
            saveButton.animation = "shake"
            saveButton.animate()
        }
        
        drawingView.layer.borderWidth = 4.0
    }
    
    //ポストの処理
    func SavePost(UserID: String, Title: String, Category: Int, IMG: String) {
        let request: Request = Request()

        let body = ["userid": UserID,
                    "filedata": IMG,
                    "title": Title,
                    "category": Category] as [String: Any]
        
        request.post(RequestConst().postContentsURI, body: body)
    }
    
    @IBAction func SaveCancel(_ sender: AnyObject) {
        CollisionDetection(SaveView, ONOFF: true)
    }
    
    @IBAction func SwipeSaveCancel(_ sender: AnyObject) {
        CollisionDetection(SaveView, ONOFF: true)
    }
    
    //画像をNSDataに変換
    func Image2String(_ image: UIImage) -> String? {
        
        guard let data = UIImagePNGRepresentation(image) else {
            return nil
        }
        
        //BASE64のStringに変換する
        let encodeString =
            data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        return encodeString
        
    }
    
    //UIimageを円に切り抜く
    func getMaskedImage(_ Img: UIImage) -> UIImage {
        let maskImgre = maskImage.cgImage!
        let mask = CGImage(maskWidth: maskImgre.width,
                           height: maskImgre.height,
                           bitsPerComponent: maskImgre.bitsPerComponent,
                           bitsPerPixel: maskImgre.bitsPerPixel,
                           bytesPerRow: maskImgre.bytesPerRow,
                           provider: maskImgre.dataProvider!, decode: nil, shouldInterpolate: false)
        let maskedImageCG: CGImage = Img.cgImage!.masking(mask!)!
        let maskedImage = UIImage(cgImage: maskedImageCG)
        return maskedImage
    }
    
    // 新規作成
    @IBAction func NewCreate(_ sender: AnyObject) {
        SaveAlert("新規作成", ViewName: "selectGraphic")
    }
    
    //viewname変更
    @IBAction func Home(_ sender: AnyObject) {
        SaveAlert("Home", ViewName: "Home")
    }
    
    //viewname変更
    @IBAction func Serch(_ sender: AnyObject) {
        SaveAlert("検索", ViewName: "searchscreen")
    }
    
    @IBAction func Logout(_ sender: AnyObject) {
        SaveAlert("ログアウト", ViewName: "Title")
    }
    
    /*--- 単体function ----*/
    
    //エラー画面
    func ErrorWindow() {
        
        UIAlertController(title: "エラー", message: "予期せぬエラーが発生しました。\n再起動しますか?", preferredStyle: .alert)
            .addAction(title: "OK")
            .show()
    }
    
    //list on/of
    func CollisionDetection(_ view: SpringView, ONOFF: Bool) {
        if ONOFF {
            Tooltable.isUserInteractionEnabled = true
            Ellipse_F.isUserInteractionEnabled = true
            Ellipse_S.isUserInteractionEnabled = true
            Rect_F.isUserInteractionEnabled = true
            Rect_S.isUserInteractionEnabled = true
            L_width1.isUserInteractionEnabled = true
            L_width2.isUserInteractionEnabled = true
            L_width3.isUserInteractionEnabled = true
            Reset.isUserInteractionEnabled = true
            UnDo.isUserInteractionEnabled = true
            ReDo.isUserInteractionEnabled = true
            drawingView.isUserInteractionEnabled = true
            view.animation = "fadeOut"
            view.animate()
            
        } else {
            Tooltable.isUserInteractionEnabled = false
            Ellipse_F.isUserInteractionEnabled = false
            Ellipse_S.isUserInteractionEnabled = false
            Rect_F.isUserInteractionEnabled = false
            Rect_S.isUserInteractionEnabled = false
            L_width1.isUserInteractionEnabled = false
            L_width2.isUserInteractionEnabled = false
            L_width3.isUserInteractionEnabled = false
            Reset.isUserInteractionEnabled = false
            UnDo.isUserInteractionEnabled = false
            ReDo.isUserInteractionEnabled = false
            drawingView.isUserInteractionEnabled = false
            view.isHidden = false
        }
    }
    
    //未保存時の画面移動アラート
    func SaveAlert(_ Title: String, ViewName: String) {
        if  SaveFlag.1 == 0 && SaveFlag.0 == 0 {
            
            UIAlertController(title: Title, message: "編集した画像が保存されていません。\n保存しますか?", preferredStyle: .alert)
                .addAction(title: "保存") { _ in
                    self.showSaveDialog()
                }
                .addAction(title: "保存しない") { _ in
                    self.transition(viewName: ViewName)
                }
                .addAction(title: "CANCEL", style: .cancel)
                .show()
        } else {
            transition(viewName: ViewName)
        }
    }
    
    func transition(viewName: String) {
        let targetView = self.storyboard!.instantiateViewController(withIdentifier: viewName)
        self.present(targetView, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
