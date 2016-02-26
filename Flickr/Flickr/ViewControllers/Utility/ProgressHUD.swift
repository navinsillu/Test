//
//  ProgressHUD.swift
//  USU ACCESS
//
//  Created by ev_mac5 on 19/12/15.
//  Copyright © 2015 ev_mac16. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func fromRGB(rgb:UInt32) -> UIColor {
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    class func fromRGB_Alpha(rgb:UInt32,alpha:Float) -> UIColor {
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
}

class ProgressHUD: UIView {

    var multiColorLoader : BLMultiColorLoader!
    static var _shared : ProgressHUD! = nil

    override init(frame:CGRect) {
        super.init(frame:frame)
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.5)
        multiColorLoader = BLMultiColorLoader(frame: CGRectMake((frame.size.width/2)-25, (frame.size.height/2)-25, 50, 50))
        multiColorLoader.lineWidth = 3.0
        multiColorLoader.theColorArray = [ UIColor.fromRGB(0xFFCD0F),UIColor.fromRGB(0xFF0064),UIColor.fromRGB(0x6E238E),UIColor.fromRGB(0x78C239),UIColor.fromRGB(0x0099CA)]
        self.addSubview(multiColorLoader)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func shared() -> ProgressHUD!
    {
        struct Tokens { static var onceToken: dispatch_once_t = 0 }
        dispatch_once(&Tokens.onceToken) { () -> Void in
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            _shared = ProgressHUD(frame: CGRectMake(0, 0, screenSize.width, screenSize.height))
        }
        
        return _shared
    }
    
    func hide()
    {
        self.removeFromSuperview()
    }
    
    func show()
    {
        self.frame=UIScreen.mainScreen().bounds;
        multiColorLoader.startAnimation()
       UIApplication.sharedApplication().delegate?.window?!.addSubview(self)
    }
}
