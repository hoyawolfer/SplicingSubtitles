//
//  UIViewExtension.swift
//  TextInImage
//
//  Created by hyw on 2024/4/12.
//

import Foundation
import MBProgressHUD

extension UIView {
    
    public func toast(_ text: String?, completion: (() -> Void)? = nil) {
        if Thread.isMainThread {
            self.showHud(text)
        } else {
            DispatchQueue.main.async {
                self.showHud(text)
            }
        }
        
        guard let completion = completion else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            completion()
        })
    }
    
    public func loadingHud(_ text: String? = nil) {
        if Thread.isMainThread {
            self.loading(text)
        } else {
            DispatchQueue.main.async {
                self.loading(text)
            }
        }
    }
    
    public func hideHud() {
        if Thread.isMainThread {
            MBProgressHUD.hide(for: self, animated: true)
        } else {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self, animated: true)
            }
        }
    }
    
    private func loading(_ text: String? = nil) {
        for view in self.subviews {
            if view.isKind(of: MBProgressHUD.self) {
                return ;
            }
        }
        UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self]).color = UIColor.white

        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .indeterminate
        hud.bezelView.color = .black
        hud.bezelView.style = .solidColor

        if let text = text {
            hud.detailsLabel.text = text
            hud.detailsLabel.font = UIFont.systemFont(ofSize: 14)
            hud.detailsLabel.textColor = .white
        }
    }
    
    private func showHud(_ text: String?, completion: (() -> Void)? = nil) {
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .text
        hud.bezelView.style = .solidColor
        hud.bezelView.color = .black;    //背景颜色

        if let text = text {
            hud.detailsLabel.text = text
            hud.detailsLabel.font = UIFont.systemFont(ofSize: 14)
            hud.detailsLabel.textColor = .white
        }
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: 1.5)
    }
    
    //显示带进度值的进度条
    public func showProgressHud(progress: Float, title: String, addToView: UIView? = nil) {
        var needCreate = true
        if let hud = self.hud, hud.mode == .annularDeterminate{
            needCreate = false
        }
        
        let progressViewWidth:CGFloat = 60
        if needCreate {
            self.hideHud()
            
            self.hud = MBProgressHUD.showAdded(to: addToView ?? self, animated: true)

            self.hud!.mode = .annularDeterminate
            self.hud!.bezelView.color = .black
            self.hud!.bezelView.style = .solidColor
            self.hud!.detailsLabel.text = title
            self.hud!.detailsLabel.textColor = .white
            
            if let indicatorView = self.hud!.value(forKey: "indicator") as? MBRoundProgressView {
                indicatorView.progressTintColor = .white
                indicatorView.backgroundTintColor = .white.withAlphaComponent(0.5)
            }
        }
        
        self.hud!.progress = progress
        self.hud!.detailsLabel.text = title
        self.hud!.layoutIfNeeded()
        
        if let indicatorView = self.hud!.value(forKey: "indicator") as? MBRoundProgressView {
            
            let constraints = indicatorView.constraints
            for cons in constraints {
                if cons.constant != progressViewWidth {
                    cons.constant = progressViewWidth
                }
                
            }
        }
    }
    
    private struct AssociatedKeys {
        static var hudKey = "hudKey"
    }
    
    var hud: MBProgressHUD? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.hudKey) as? MBProgressHUD
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.hudKey,
                newValue as MBProgressHUD?,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
