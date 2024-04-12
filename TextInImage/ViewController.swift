//
//  ViewController.swift
//  TextInImage
//
//  Created by hyw on 2024/4/11.
//

import UIKit
import Photos
import AssetsLibrary
import CommonCrypto
import HandyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var tanslateBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var chooseBtn: UIButton!
    // - 相机
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var waterMarkTF: UITextField!
    private var cameraPickerCtrl = UIImagePickerController()
    
    var trans_result: [Trans_result]?
    var selectImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveBtn.setTitle("", for: .normal)
        textView.delegate = self;
//        textView.text = "人生这道选择题无论怎么选都回有遗憾\n但人们总认为没有的录上开满鲜花\n 凡事看的太透，人间便无趣了\n 该来的总会来，该走的也都会走\n 别抗拒，别挽留\n 太注重细节的人注定不会快乐"
        bgView.clipsToBounds = false
        waterMarkTF.delegate = self
        waterMarkTF.text = UserDefaults.standard.string(forKey: "nickname")
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.backgroundColor = .white
        tanslateBtn.setImage(UIImage(named: "trans"), for: .normal)
        tanslateBtn.setImage(UIImage(named: "trans_dis"), for: .disabled)
        slider.isHidden = true
        saveBtn.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    var defaultMargin: CGFloat = 40.0
    var imgHeight: CGFloat = 0
    var imgWidth: CGFloat = UIScreen.main.bounds.width
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UserDefaults.standard.set(textField.text ?? "", forKey: "nickname")
        configSubView(image: selectImage)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        getTanslate(text: textView.text)
    }
    
    

    @IBAction func translateAction(_ sender: Any) {
        getTanslate(text: textView.text)
    }
    @IBAction func saveAction(_ sender: UIButton) {
        chooseBtn.isEnabled = false
        self.view.loadingHud("保存中...")
        let img = bgView.makeImage()
        UIImageWriteToSavedPhotosAlbum(img, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func getTanslate(text: String) {
        let str = String(data: text.data(using: .utf8)!, encoding: .utf8)!
        let sign = ("20240411002021105" + str + "salt" + "KX049NLrTpaU9X8ObbDg").md5
        let params: [String: Any] = [
            "q": str,
            "from": "auto",
            "to": "en",
            "appid": "20240411002021105",
            "salt": "salt",
            "sign": sign
        ]
        tanslateBtn.isEnabled = false
        Service.get("/api/trans/vip/translate", parameters: params, model: Model.self) {[weak self] returnData in
            self?.trans_result = returnData?.trans_result
            self?.tanslateBtn.isEnabled = true
            if (self?.trans_result?.count ?? 0) <= 0 {
                self?.view.toast("翻译失败，请重试")
            } else {
                self?.view.toast("翻译成功")
                self?.configSubView(image: self?.selectImage)
            }
        }
        
    }
    
    //保存图片
    @objc func image(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        self.view.hideHud()
        chooseBtn.isEnabled = true
       if error == nil{
           self.view.toast("保存成功")
       }else{
           self.view.toast("保存失败，请重试")
       }
    }
    
    @IBAction func ratioChanged(_ sender: UISlider) {
        print("\(sender.value)")
        configMargins(ratio: CGFloat(sender.value))
        
    }
    @IBAction func chooseAction(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.delegate = self
//        let vc = TZImagePickerController(maxImagesCount: 1, delegate: self)
//        vc?.showSelectBtn = false
////        vc?.allowCrop = true
////        vc?.scaleAspectFillCrop = true
//        vc?.allowPickingImage = true
//        vc?.allowPickingVideo = false
//        vc?.sortAscendingByModificationDate = true
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func configMargins(ratio: CGFloat) {
        let margin = defaultMargin * ratio
        for index in 0..<bgView.subviews.count {
            if let view = bgView.viewWithTag(index) {
                var frame = view.frame
                frame.origin.y = margin * CGFloat(index)
                view.frame = frame
            }
            
        }
        bgView.frame = CGRect(x: 0, y: 230, width: imgWidth, height: imgHeight + margin * CGFloat(bgView.subviews.count - 1))

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {[weak self] in
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            self?.configSubView(image: image)
        }
        
    }
    
    func configSubView(image: UIImage?) {
        guard let image = image else { return }
        slider.isHidden = false
        saveBtn.isHidden = false
        self.selectImage = image
        for view in bgView.subviews {
            view.removeFromSuperview()
        }
        let texts = self.textView.text.components(separatedBy: "\n")
        let screenWidth = UIScreen.main.bounds.width
        self.imgHeight = imgWidth * (image.size.height / image.size.width)
        self.bgView.frame = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
        for (index, text) in texts.enumerated() {
            let imgView = UIImageView()
            imgView.tag = index
            imgView.contentMode = .scaleAspectFill
            if index < (trans_result?.count ?? 0) {
                let img = image.drawTextInImage(text: text, enText: trans_result?[index].dst, waterMark: waterMarkTF.text)
                imgView.image = img
            } else {
                let img = image.drawTextInImage(text: text, enText: nil, waterMark: waterMarkTF.text)
                imgView.image = img
            }
            
            imgView.frame = CGRectMake(0, 0, imgWidth, imgHeight)
            bgView.addSubview(imgView)
            bgView.sendSubviewToBack(imgView)
        }
        configMargins(ratio: 1)
    }
    
}
extension UIView{
    //生成图片
    func makeImage() -> UIImage {
        let size = self.bounds.size
        let format = UIGraphicsImageRendererFormat()
        format.prefersExtendedRange = true
        let rect = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(bounds: rect, format: format)
        let image = renderer.image { (context)  in
           context.cgContext.concatenate(CGAffineTransform.identity.scaledBy(x: 1, y: 1))
            return self.layer.render(in: context.cgContext)
        }
        return image
    }
    
}
extension UIImage {
    func drawTextInImage(text: String, enText: String?, waterMark: String?)->UIImage {
        //开启图片上下文
        UIGraphicsBeginImageContext(self.size)
        //图形重绘
        self.draw(in: CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height))
        //水印文字属性
        let fontSize: CGFloat = self.size.width / 22.0
        let att = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: fontSize)]
        //水印文字大小
        let size = text.size(withAttributes: att)
        //绘制文字
        text.draw(in: CGRect.init(x: self.size.width / 2.0 - size.width / 2.0 - 10, y: self.size.height - size.height * 2, width: size.width, height: size.height), withAttributes: att)
        
        if let enText = enText {
            //水印文字属性
            let enFontSize: CGFloat = self.size.width / 40
            let enAtt = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: enFontSize)]
            //水印文字大小
            let enSize = enText.size(withAttributes: enAtt)
            if (size.width >= self.size.width) {
                //绘制文字
                enText.draw(in: CGRect.init(x: enSize.width, y: self.size.height - enSize.height * 1.5, width: self.size.width - 2 * enSize.width, height: enSize.height), withAttributes: enAtt)
            } else {
                //绘制文字
                enText.draw(in: CGRect.init(x: self.size.width / 2.0 - enSize.width / 2.0 - 10, y: self.size.height - enSize.height * 2, width: enSize.width, height: enSize.height), withAttributes: enAtt)
            }
        }
        
        if let waterMark = waterMark {
            //水印文字属性
            let waterMarkAtt = [NSAttributedString.Key.foregroundColor:UIColor.lightGray,NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: fontSize / 1.5)]
            //水印文字大小
            let waterMarkSize = waterMark.size(withAttributes: waterMarkAtt)
            //绘制文字
            waterMark.draw(in: CGRect.init(x: fontSize / 2.0, y: fontSize / 2.0, width: waterMarkSize.width, height: waterMarkSize.height), withAttributes: waterMarkAtt)
        }
        
        //从当前上下文获取图片3
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        
        return image!
        
    }
        
    func drawWaterMarkInImage(text: String)->UIImage {
        //开启图片上下文
        UIGraphicsBeginImageContext(self.size)
        //图形重绘
        self.draw(in: CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height))
        //水印文字属性
        let att = [NSAttributedString.Key.foregroundColor:UIColor.lightGray,NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 30)]
        //水印文字大小
        let size = text.size(withAttributes: att)
        //绘制文字
        text.draw(in: CGRect.init(x: 10, y: 20, width: size.width, height: size.height), withAttributes: att)
        //从当前上下文获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        
        return image!
        
    }
}

extension String {
    
    var md5: String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate()
        return hash as String
    }
    
    //将原始的url编码为合法的url
    func urlEncoded(_ characterSet: CharacterSet? = nil) -> String {
        var encodeUrlString: String? = nil
        if let characterSet = characterSet {
            encodeUrlString = self.addingPercentEncoding(withAllowedCharacters: characterSet)
        }
        else {
            let mstring = self.replacingOccurrences(of: " ", with: "+")
            let set = CharacterSet(charactersIn: "!*'();:@&=+ $,./?%#[]")
            encodeUrlString = mstring.addingPercentEncoding(withAllowedCharacters: set)
        }
        
        return encodeUrlString ?? ""
    }
}

struct Model: HandyJSON {
    var from: String?
    var to: String?
    var trans_result: [Trans_result]?
}

struct Trans_result: HandyJSON {
    var src: String?
    var dst: String?
}
