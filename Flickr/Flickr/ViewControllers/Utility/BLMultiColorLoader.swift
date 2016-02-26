//
//  BLMultiColorLoader.swift
//  USU ACCESS
//
//  Created by ev_mac5 on 18/12/15.
//  Copyright © 2015 ev_mac16. All rights reserved.
//

import UIKit

class BLMultiColorLoader: UIView {

    var theColorArray : NSArray!
    var lineWidth : CGFloat!
    var circleLayer : CAShapeLayer!
    var strokeLineAnimation : CAAnimationGroup!
    var rotationAnimation : CAAnimation!
    var strokeColorAnimation : CAAnimation!
    var animating : Bool!

    let DEFAULT_LINE_WIDTH : CGFloat =  2.0
    let ROUND_TIME =  1.33 as Double
    let DEFAULT_COLOR =  UIColor(red: 254.0/255.0, green: 203.0/255.0, blue: 51.0/255.0, alpha: 1)


    override init(frame:CGRect) {
        super.init(frame:frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
        fatalError("init(coder:) has not been implemented")
    }

    func initialSetup()
    {
        circleLayer = CAShapeLayer()
        self.layer.addSublayer(circleLayer)
        
        self.backgroundColor = UIColor.clearColor()
        circleLayer.fillColor = nil
        self.circleLayer.lineWidth = DEFAULT_LINE_WIDTH
        self.circleLayer.lineCap = kCALineCapRound;
        
        theColorArray = [DEFAULT_COLOR]
        
        self.updateAnimations()
    }
    
    // Mark: - Layout
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0)
        let radius = min(self.bounds.size.width, self.bounds.size.height)/2.0 - self.circleLayer.lineWidth / 2.0
        let startAngle = 0.0 as CGFloat
        let endAngle = 2 * M_PI
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: CGFloat(endAngle), clockwise: true)

        self.circleLayer.path = path.CGPath;
        self.circleLayer.frame = self.bounds;
    }
    
    // Mark : -
    
    func setColorArray(_colorArray : NSArray)
    {
        if(theColorArray.count>0)
        {
            theColorArray = _colorArray;
        }
        updateAnimations()
    }
    
    func setLineWidth(_lineWidth : CGFloat)
    {
        lineWidth = _lineWidth
        self.circleLayer.lineWidth = lineWidth
    }
    
    func stopAnimationAfter(timeInterval : NSTimeInterval)
    {
        self.performSelector("stopAnimation", withObject: nil, afterDelay: timeInterval)
    }
    
    func isAnimating() -> Bool
    {
        return animating;

    }

     // Mark: -
    
    func startAnimation()
    {
        animating = true;
        self.circleLayer.addAnimation(self.strokeLineAnimation, forKey: "strokeLineAnimation")
        self.circleLayer.addAnimation(self.rotationAnimation, forKey: "rotationAnimation")
        self.circleLayer.addAnimation(self.strokeColorAnimation, forKey: "strokeColorAnimation")
    }
    
    func stopAnimation()
    {
        animating = false;
        self.circleLayer.removeAnimationForKey( "strokeLineAnimation")
        self.circleLayer.removeAnimationForKey( "rotationAnimation")
        self.circleLayer.removeAnimationForKey( "strokeColorAnimation")
    }
    
    func updateAnimations()
    {
        // Stroke Head
        let headAnimation = CABasicAnimation(keyPath: "strokeStart")
        headAnimation.beginTime = ROUND_TIME/3.0
        headAnimation.fromValue = 0
        headAnimation.toValue = 1
        headAnimation.duration = 2*ROUND_TIME/3.0
        headAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // Stroke Tail
        let tailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        tailAnimation.fromValue = 0
        tailAnimation.toValue = 1
        tailAnimation.duration = 2*ROUND_TIME/3.0
        tailAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // Stroke Line Group
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = ROUND_TIME
        animationGroup.repeatCount = Float.infinity
        animationGroup.animations = [headAnimation, tailAnimation]
        self.strokeLineAnimation = animationGroup
        
        // Rotation
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2*M_PI
        rotationAnimation.duration = 2*ROUND_TIME/3.0
        animationGroup.repeatCount = Float.infinity
        self.rotationAnimation = rotationAnimation;
        
        let strokeColorAnimation = CAKeyframeAnimation(keyPath: "strokeColor")
        strokeColorAnimation.values = prepareColorValues() as [AnyObject]
        strokeColorAnimation.keyTimes = prepareKeyTimes() as? [NSNumber]
        strokeColorAnimation.calculationMode = kCAAnimationDiscrete
        strokeColorAnimation.duration = Double(theColorArray.count) * ROUND_TIME
        strokeColorAnimation.repeatCount = Float.infinity
        self.strokeColorAnimation = strokeColorAnimation
    }
    
    //Mark: - Animation Data Preparation

    func prepareColorValues() -> NSArray
    {
        let cgColorArray = NSMutableArray()
        
        for color in theColorArray
        {
            cgColorArray.addObject(color.CGColor)
        }

        return cgColorArray;
    }
    
    func prepareKeyTimes() -> NSArray
    {
        let keyTimesArray = NSMutableArray()
        
        for(var i=0 as Int; i < theColorArray.count+1; i++)
        {
            keyTimesArray.addObject(NSNumber(integer: i * 1 / theColorArray.count))
        }
        
        return keyTimesArray;
    }

     deinit
    {
        stopAnimation()
        self.circleLayer.removeFromSuperlayer()
        self.circleLayer = nil;
        self.strokeLineAnimation = nil;
        self.rotationAnimation = nil;
        self.strokeColorAnimation = nil;
        theColorArray = nil;
    }
}

