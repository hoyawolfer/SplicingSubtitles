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
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var tanslateBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var chooseBtn: UIButton!
    @IBOutlet weak var ocrBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    // - 相机
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var waterMarkTF: UITextField!
    private var cameraPickerCtrl = UIImagePickerController()
    
    @IBOutlet weak var zhTitleLab: UILabel!
    @IBOutlet weak var enTitleLab: UILabel!
    @IBOutlet weak var marginTitLab: UILabel!
    
    @IBOutlet weak var zhSlider: UISlider!
    @IBOutlet weak var enSlider: UISlider!
    @IBOutlet weak var marginSlider: UISlider!
    
    //0 默认 创作底图 1 ocr 底图
    var chooseImgType: Int = 0
    
    var borderView: UIView = UIView()
    
    var trans_result: [Trans_result]?
    var selectImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveBtn.setTitle("", for: .normal)
        self.ocrBtn.setTitle("", for: .normal)
        self.clearBtn.setTitle("", for: .normal)
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
        hiddenToolView(true)
        
        borderView.frame = CGRect(x: 0, y: 230, width: imgWidth, height: imgWidth / 0.75)
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor.black.cgColor
        self.view.addSubview(borderView)
        self.view.sendSubviewToBack(borderView)
        // Do any additional setup after loading the view.
        
        let zhValue = UserDefaults.standard.float(forKey: "zhSlider")
        let enValue = UserDefaults.standard.float(forKey: "enSlider")
        let marginValue = UserDefaults.standard.float(forKey: "marginSlider")

        zhSlider.value = zhValue == 0 ? 1 : zhValue
        enSlider.value = enValue == 0 ? 1 : enValue
        marginSlider.value = marginValue == 0 ? 1 : marginValue

    }
    
    var defaultMargin: CGFloat = 40.0
    var imgHeight: CGFloat = 0
    var imgWidth: CGFloat = UIScreen.main.bounds.width
    
    
    func hiddenToolView(_ isHidden: Bool) {
        zhTitleLab.isHidden = isHidden
        enTitleLab.isHidden = isHidden
        marginTitLab.isHidden = isHidden
        zhSlider.isHidden = isHidden
        enSlider.isHidden = isHidden
        marginSlider.isHidden = isHidden
        slider.isHidden = isHidden
        saveBtn.isHidden = isHidden
    }
    
    @IBAction func clearAction(_ sender: Any) {
        textView.text = ""
    }
    func recognizeTextRequest(image: UIImage) {
        // 初始化 VNImageRequestHandler
        var cgOrientation = CGImagePropertyOrientation.right
        switch image.imageOrientation {
            case .up: cgOrientation = .up
            case .upMirrored: cgOrientation = .upMirrored
            case .down: cgOrientation = .down
            case .downMirrored: cgOrientation = .downMirrored
            case .left: cgOrientation = .left
            case .leftMirrored: cgOrientation = .leftMirrored
            case .right: cgOrientation = .right
            case .rightMirrored: cgOrientation = .rightMirrored
        @unknown default:
            fatalError()
        }
        
        guard let cgImage = image.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: cgOrientation)
        // 初始化 VNRecognizeTextRequest
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        
        // 默认情况下不会识别中文，需要手动指定 recognitionLanguages
        request.recognitionLanguages = ["zh-Hans", "zh-Hant"]
        request.usesLanguageCorrection = true
        // 执行 request
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Unable to perform the requests: \(error).")
            }
        }
    }

    func recognizeTextHandler(request: VNRequest, error: Error?) {
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            DispatchQueue.main.async {
                let recognizedStrings = observations.compactMap { observation in
                    return observation.topCandidates(1).first?.string
                }
                self.textView.text = self.removeEnglishCharacters(from: recognizedStrings.joined(separator: "\n"))
//                print(recognizedStrings)
            }
    }
    
    func removeEnglishCharacters(from input: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Za-z]", options: [])
            let range = NSRange(location: 0, length: input.utf16.count)
            let noEnglishString = regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: "")
            return noEnglishString.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n\n", with: "\n")
        } catch {
            // 如果正则表达式有错误，返回原始字符串
            print("正则表达式错误: \(error)")
            return input
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UserDefaults.standard.set(textField.text ?? "", forKey: "nickname")
        configSubView(image: selectImage, zhFontRatio: CGFloat(zhSlider.value), enFontRatio: CGFloat(enSlider.value), marginRatio: CGFloat(marginSlider.value))
        

    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
//        getTanslate(text: textView.text)
        configSubView(image: selectImage, zhFontRatio: CGFloat(zhSlider.value), enFontRatio: CGFloat(enSlider.value), marginRatio: CGFloat(marginSlider.value))

    }
    
    @IBAction func ocrAction(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.chooseImgType = 1
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func zhSliderChanged(_ sender: UISlider) {
        UserDefaults.standard.set(sender.value, forKey: "zhSlider")
        configSubView(image: self.selectImage, zhFontRatio: CGFloat(zhSlider.value), enFontRatio: CGFloat(enSlider.value), marginRatio: CGFloat(marginSlider.value))
    }
    @IBAction func enSliderChanged(_ sender: UISlider) {
        UserDefaults.standard.set(sender.value, forKey: "enSlider")
        configSubView(image: self.selectImage, zhFontRatio: CGFloat(zhSlider.value), enFontRatio: CGFloat(enSlider.value), marginRatio: CGFloat(marginSlider.value))
    }
    
    @IBAction func marginSliderChanged(_ sender: UISlider) {
        UserDefaults.standard.set(sender.value, forKey: "marginSlider")
        configSubView(image: self.selectImage, zhFontRatio: CGFloat(zhSlider.value), enFontRatio: CGFloat(enSlider.value), marginRatio: CGFloat(marginSlider.value))
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
                self?.configSubView(image: self?.selectImage, zhFontRatio: CGFloat(self!.zhSlider.value), enFontRatio: CGFloat(self!.enSlider.value), marginRatio: CGFloat(self!.marginSlider.value))

            }
        }
        
    }
    
//    {
//        "refresh_token": "25.87871ab760b6700321ecdbe4f9812b62.315360000.2028697207.282335-61888234",
//        "expires_in": 2592000,
//        "session_key": "9mzdCPBrzMi2txdVfrs0xxnl+oVsCxUpWyKYjKlY2RSq7qRDrGpDz6npqLUR6nxnXDy1D+myCfmsu+ZJUg5F1f+xgNpQQg==",
//        "access_token": "24.348395bd809d2522f014b088d4a23c76.2592000.1715929207.282335-61888234",
//        "scope": "public brain_all_scope brain_ocr_general_basic wise_adapt lebo_resource_base lightservice_public hetu_basic lightcms_map_poi kaidian_kaidian ApsMisTest_Test权限 vis-classify_flower lpq_开放 cop_helloScope ApsMis_fangdi_permission smartapp_snsapi_base smartapp_mapp_dev_manage iop_autocar oauth_tp_app smartapp_smart_game_openapi oauth_sessionkey smartapp_swanid_verify smartapp_opensource_openapi smartapp_opensource_recapi fake_face_detect_开放Scope vis-ocr_虚拟人物助理 idl-video_虚拟人物助理 smartapp_component smartapp_search_plugin avatar_video_test b2b_tp_openapi b2b_tp_openapi_online smartapp_gov_aladin_to_xcx",
//        "session_secret": "67eb49b087fa775b1f66319e6ee38afc"
//    }
    
    func ocrTextInImage(image: UIImage) {
        recognizeTextRequest(image: image)
//        textView.text = ""
//        let str = image.toStr()
//
//        Service.postbaidubce("/rest/2.0/ocr/v1/general_basic", parameters: ["image": str, "postUrlParameter": "1", "detect_direction": "false", "detect_language": "false", "paragraph": "false", "probability": "false"], model: WordsModel.self) { returnData in
//            print(returnData?.words_result_num ?? 0)
//        }
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
        vc.modalPresentationStyle = .fullScreen
        self.chooseImgType = 0
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
            if self?.chooseImgType == 0 {
                self?.configSubView(image: image, zhFontRatio: CGFloat(self!.zhSlider.value), enFontRatio: CGFloat(self!.enSlider.value), marginRatio: CGFloat(self!.marginSlider.value))
            } else {
                self?.ocrTextInImage(image: image)
            }
            
        }
        
    }
    
    func configSubView(image: UIImage?, zhFontRatio: CGFloat = 1, enFontRatio: CGFloat = 1, marginRatio: CGFloat = 1) {
        guard let image = image else { return }
        hiddenToolView(false)
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
                let img = image.drawTextInImage(text: text, enText: trans_result?[index].dst, waterMark: waterMarkTF.text, zhFontRatio: zhFontRatio, enFontRatio: enFontRatio, marginRatio: marginRatio)
                imgView.image = img
            } else {
                let img = image.drawTextInImage(text: text, enText: nil, waterMark: waterMarkTF.text, zhFontRatio: zhFontRatio, enFontRatio: enFontRatio, marginRatio: marginRatio)
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
    func drawTextInImage(text: String, enText: String?, waterMark: String?, zhFontRatio: CGFloat = 1, enFontRatio: CGFloat = 1, marginRatio: CGFloat = 1)->UIImage {
        //开启图片上下文
        UIGraphicsBeginImageContext(self.size)
        //图形重绘
        self.draw(in: CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let fontSize: CGFloat = self.size.width / 30 * zhFontRatio
        let att = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: fontSize)]
        //水印文字大小
        let size = text.size(withAttributes: att)
        let margin: CGFloat = (self.size.width / 30) * (marginRatio - 1)
        let bottomMargin: CGFloat = (self.size.width / 50)
        
        if let enText = enText {
            //英文文字属性
            let enFontSize: CGFloat = self.size.width / 40 * enFontRatio
            let enAtt = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: enFontSize)]
            //水印文字大小
            let enSize = enText.size(withAttributes: enAtt)
            if (size.width >= self.size.width) {
                //绘制文字
                enText.draw(in: CGRect.init(x: enSize.width, y: self.size.height - bottomMargin - enSize.height, width: self.size.width - 2 * enSize.width, height: enSize.height), withAttributes: enAtt)
            } else {
                //绘制文字
                enText.draw(in: CGRect.init(x: self.size.width / 2.0 - enSize.width / 2.0 - 10, y: self.size.height - bottomMargin - enSize.height, width: enSize.width, height: enSize.height), withAttributes: enAtt)
            }
            //绘制文字
            text.draw(in: CGRect.init(x: self.size.width / 2.0 - size.width / 2.0 - 10, y: self.size.height - enSize.height - size.height - bottomMargin * 1.3 - margin, width: size.width, height: size.height), withAttributes: att)

        } else {
            //绘制文字
            text.draw(in: CGRect.init(x: self.size.width / 2.0 - size.width / 2.0 - 10, y: self.size.height - size.height - bottomMargin - margin, width: size.width, height: size.height), withAttributes: att)
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
    
    func toStr() -> String{
        let dataTmp = self.pngData()
        if let data = dataTmp {
            let imageStrTT = data.base64EncodedString()
            return imageStrTT
        }
        return ""
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


struct WordsModel: HandyJSON {
    var words_result_num: Int?
    var words_result: [WordModel]?
}

struct WordModel: HandyJSON {
    var words: String?
}

struct Trans_result: HandyJSON {
    var src: String?
    var dst: String?
}
