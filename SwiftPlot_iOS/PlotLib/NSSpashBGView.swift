//
//  NSSpashBGView.swift
//  NativeSigP
//
//  Created by Kalanyu Zintus-art on 10/27/15.
//  Copyright © 2015 KoikeLab. All rights reserved.
//

import UIKit

struct SplashBGPosition {
    var TopLeft = CGPoint(x:0, y:1)
    var TopRight = CGPoint(x:1, y:1)
    var BottomLeft = CGPoint(x:0 ,y:0)
    var BottomRight = CGPoint(x:1, y:0)
}

enum SplashDirection {
    case Left
    case Right
}

protocol NSSPlashViewDelegate {
    func splashAnimationEnded(startedFrom from: SplashDirection)
}

class NSSpashBGView: UIView {
    
    var delegate: NSSPlashViewDelegate?
    let splashLayer = CALayer()
    private var splashColor : UIColor = UIColor.whiteColor()
    private let initialSplashSize : CGFloat = 50
    
    required override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
//        self.wantsLayer = true
        self.splashLayer.delegate = self
//        self.splashLayer.autoresizingMask = [.LayerWidthSizable, .LayerHeightSizable]
//        self.layer?.autoresizingMask = [.LayerWidthSizable, .LayerHeightSizable]
        self.layer.addSublayer(splashLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
//        self.wantsLayer = true
        self.splashLayer.delegate = self
//        self.layer.autoresizingMask = [.LayerWidthSizable, .LayerHeightSizable]
//        self.splashLayer.autoresizingMask = [.LayerWidthSizable, .LayerHeightSizable]
        self.layer.addSublayer(splashLayer)
    }
    
    override func drawRect(dirtyRect: CGRect) {
        super.drawRect(dirtyRect)
        // Drawing code here.
    }
    
    override func drawLayer(layer: CALayer, inContext ctx: CGContext) {
        
        if layer === splashLayer {

            let circlePath = UIBezierPath()
            CGContextBeginPath(ctx)
            circlePath.appendPath(UIBezierPath(ovalInRect: CGRectMake(0 - (initialSplashSize/2),0 - (initialSplashSize/2), initialSplashSize, initialSplashSize)))
            CGContextAddPath(ctx, circlePath.CGPath)
            CGContextClosePath(ctx)
            CGContextSetFillColorWithColor(ctx, splashColor.CGColor)
            CGContextFillPath(ctx)
        }
    }
    
    func initLayers() {
        self.splashLayer.bounds = self.bounds

        self.splashLayer.anchorPoint = CGPoint(x: 0, y: 0)

        self.splashLayer.contentsScale = 2
//        self.splashLayer.bounds.origin.x = self.frame.maxX
        self.splashLayer.setNeedsDisplay()
        
//        splashFill(toColor: UIColor.whiteColor())
        
    }
    
    func splashFill(toColor color: UIColor,_ splashDirection: SplashDirection) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.splashColor = color
            self.splashLayer.setNeedsDisplay()
            self.splashLayer.transform = CATransform3DMakeScale(1, 1, 1)
            
            if splashDirection == .Right {
                CATransaction.begin()
                CATransaction.setAnimationDuration(0)
                let translate = CATransform3DTranslate(self.splashLayer.transform, self.bounds.maxX, 0, 0)
                self.splashLayer.transform = CATransform3DRotate(translate,CGFloat(M_PI), 0, -1, 0)
                CATransaction.commit()
            }
            
            //        self.layer?.addSublayer(splashLayer)
            
            CATransaction.begin()
            
            CATransaction.setCompletionBlock({
                //            self.splashLayer.transform = CATransform3DScale(self.splashLayer.transform, round(self.bounds.size.width * 3 / self.initialSplashSize), round(self.bounds.size.width * 3 / self.initialSplashSize), 1)
                self.layer.backgroundColor = self.splashColor.CGColor
                self.splashLayer.backgroundColor = self.splashColor.CGColor
                self.delegate?.splashAnimationEnded(startedFrom: splashDirection)
                
                //            self.splashLayer.removeFromSuperlayer()
            })
            
            let animation = CABasicAnimation(keyPath: "transform")
            animation.duration = 0.3
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            animation.toValue = NSValue(CATransform3D: CATransform3DScale(self.splashLayer.transform, round(self.bounds.size.width * 3 / self.initialSplashSize), round(self.bounds.size.width * 3 / self.initialSplashSize), 1))
            animation.fillMode = kCAFillModeForwards
            animation.removedOnCompletion = false
            self.splashLayer.addAnimation(animation, forKey: "transform")
            CATransaction.commit()
            })

    }
    
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        splashLayer.setNeedsDisplay()
        self.layer.setNeedsDisplay()
    }
}
