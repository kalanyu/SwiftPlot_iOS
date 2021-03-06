//
//  AxesDrawer.swift
//  Calculator
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class HashDrawer
{
    private struct Constants {
        static let HashmarkSize: CGFloat = 6
    }
    var maxDataRange : Int = 1
    
    //padding parameter, moves the axes further in
    var padding = CGPointZero
    var color = UIColor.whiteColor()
//    var color = UIColor.redColor()
    
    var minimumPointsPerHashmark: CGFloat = 40
    
    // set this from UIView's contentScaleFactor to position axes with maximum accuracy
    var contentScaleFactor: CGFloat = 1
    
    var axesLabel : [Int] = [Int](0...100)
    var yLockLabels = [String](count: 100, repeatedValue: "")
    var xLockLabels = [String](count: 100, repeatedValue: "")
    // use to keep track of the moving axe label
    
    
    
    //public variables for declaring drawing coordinates to data-drawers
    var pointsPerUnit = CGPointZero
    var bounds = CGRectZero
    var position = CGPointZero
    var plotFrame = CGRectZero
    var numberOfSubticks : CGFloat = 0
    var displayLabels = true
    
    var anchorPoint = CGPointZero
    
    convenience init(color: UIColor, contentScaleFactor: CGFloat) {
        self.init()
        self.color = color
        self.contentScaleFactor = contentScaleFactor
    }
    
    convenience init(color: UIColor) {
        self.init()
        self.color = color
    }
    
    convenience init(contentScaleFactor: CGFloat) {
        self.init()
        self.contentScaleFactor = contentScaleFactor
    }
    
    // this method is the heart of the AxesDrawer
    // it draws in the current graphic context's coordinate system
    // therefore origin and bounds must be in the current graphics context's coordinate system
    // pointsPerUnit is essentially the "scale" of the axes
    // e.g. if you wanted there to be 100 points along an axis between -1 and 1,
    //    you'd set pointsPerUnit to 50
    func drawHashInRect(context: CGContext, bounds: CGRect, axeOrigin: CGPoint, xPointsToShow: CGFloat, yPointsToShow: CGFloat = 1, numberOfTicks: Int = 0, maxDataRange: Int = 1)
    {
        CGContextTranslateCTM(context, 0.0, bounds.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        //DRAWING IN LAYER CANNOT BE DONE USING NSPath Stroke
        color.set()
        self.numberOfSubticks = CGFloat(numberOfTicks)
        self.maxDataRange = max(maxDataRange, 1)
        
        let ppX = (bounds.width - padding.x) / (xPointsToShow + (displayLabels ? 0.5: 0))
        var ppY = (bounds.height - padding.y) / (yPointsToShow + (displayLabels ? 0.5: 0))
        
        //TODO: the inner frame of the graph
        
        
        let posX = (bounds.origin.x + padding.x)// + ((bounds.width - padding.x) * anchorPoint.x)
        let posY = (bounds.origin.y + padding.y) + ((bounds.height - padding.y) * anchorPoint.y)
        let position = CGPoint(x: posX, y: posY )
        
        
        //if pointsPerY is not assigned (or default)
        if yPointsToShow == 0 {
            ppY = ppX
        }
        
        self.pointsPerUnit.x = ppX
        self.pointsPerUnit.y = ppY
        self.bounds = bounds
        self.bounds = bounds
        self.position = position
        

        
        //TODO: addition fine-tuning for general purpose
        var axisPosition = position
        axisPosition.x += axeOrigin.x
        axisPosition.y += axeOrigin.y
        

        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextSetStrokeColorWithColor(context, color.CGColor)

        drawHashmarksInRect(context,bounds: bounds, origin:axisPosition, pointsPerUnit: align(ppX))
        drawFixedHashmarksInRect(context, bounds: bounds, origin: position, pointsPerUnit: align(ppY))
        
    }
    
    
    // the rest of this class is private
    private func drawFixedHashmarksInRect(context: CGContext, bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat)
    {
        //we have fix bounds , if the origin is more than bounds then the hashmark will not be drawn
        if ((origin.x >= bounds.minX) && (origin.x <= bounds.maxX)) || ((origin.y >= bounds.minY) && (origin.y <= bounds.maxY))
        {
            // figure out how many units each hashmark must represent
            // to respect both pointsPerUnit and minimumPointsPerHashmark
            var unitsPerHashmark = minimumPointsPerHashmark / pointsPerUnit
            if unitsPerHashmark < 1 {
                unitsPerHashmark = pow(10, ceil(log10(unitsPerHashmark)))
            } else {
                unitsPerHashmark = floor(unitsPerHashmark)
            }
            
            let pointsPerHashmark = pointsPerUnit * unitsPerHashmark
            //usually equals to pointsPerUnit
            
            // figure out which is the closest set of hashmarks (radiating out from the origin) that are in bounds
            var startingHashmarkRadius: CGFloat = 1
            if !CGRectContainsPoint(bounds, origin) {
                if origin.x > bounds.maxX {
                    startingHashmarkRadius = (origin.x - bounds.maxX) / pointsPerHashmark + 1
                } else if origin.x < bounds.minX {
                    startingHashmarkRadius = (bounds.minX - origin.x) / pointsPerHashmark + 1
                } else if origin.y > bounds.maxY {
                    startingHashmarkRadius = (origin.y - bounds.maxY) / pointsPerHashmark + 1
                } else {
                    startingHashmarkRadius = (bounds.minY - origin.y) / pointsPerHashmark + 1
                }
                startingHashmarkRadius = floor(startingHashmarkRadius)
            }
            
            // now create a bounding box inside whose edges those four hashmarks lie
            //            let bboxSize = pointsPerHashmark * startingHashmarkRadius * 2
            let subBboxSize = pointsPerHashmark / numberOfSubticks * startingHashmarkRadius * 2
            // check here if there's hash boundary-related bug
            //            var bbox = CGRect(center: origin, size: CGSize(width: bboxSize, height: bboxSize)) //skips to "1"'s hash if use bboxsize
            var subBbox =  CGRect(center: origin, size: CGSize(width: subBboxSize, height: subBboxSize)) //covers "0"
            
            // formatter for the hashmark labels
            let formatter = NSNumberFormatter()
            
            formatter.maximumFractionDigits = 3
            //Int(-log10(Double(unitsPerHashmark)))
            formatter.minimumIntegerDigits = 1
            
            var i = 0
            var paddedBounds = bounds
            paddedBounds.origin.y += padding.y
            
            //            while !CGRectContaiCGRect(bbox, self.bounds) {
            
            
            while numberOfSubticks > 0 && !CGRectContainsRect(subBbox, self.bounds)
            {
                var label = formatter.stringFromNumber((origin.x-subBbox.minX)/pointsPerUnit * CGFloat(self.maxDataRange))!
                //comparing rect which consists of floats after mathematic operation is difficult because of the digit in low bits...
                
                if let topHashmarkPoint = alignedPoint(x: origin.x, y: subBbox.minY, insideBounds:paddedBounds) {
                    drawHashmarkAtLocation(context, location: topHashmarkPoint, .Left("-\(label)"))
                }
                
                if let bottomHashmarkPoint = alignedPoint(x: origin.x, y: subBbox.maxY, insideBounds:paddedBounds) {
                    if !yLockLabels[i].isEmpty {
                        label = yLockLabels[i]
                    }
                    drawHashmarkAtLocation(context, location: bottomHashmarkPoint, .Left(label))
                }
                subBbox.insetInPlace(dx: -(pointsPerHashmark / numberOfSubticks), dy: -(pointsPerHashmark / numberOfSubticks))
                
                ++i
            }
            
            //                var label = formatter.stringFromNumber((origin.x-bbox.minX)/pointsPerUnit)!
            //                if !yLockLabels[i].isEmpty {
            //                    label = yLockLabels[i]
            //                }
            //
            ////                if let topHashmarkPoint = alignedPoint(x: origin.x, y: bbox.minY, insideBounds:bounds) {
            ////                    drawHashmarkAtLocation(topHashmarkPoint, .Left("-\(label)"))
            ////                }
            //
            //                if let bottomHashmarkPoint = alignedPoint(x: origin.x, y: bbox.maxY, insideBounds:bounds) {
            //                    drawHashmarkAtLocation(context, location: bottomHashmarkPoint, .Left(label))
            //                }
            //                //negative inset is out(?)set
            //                bbox.insetInPlace(dx: -pointsPerHashmark, dy: -pointsPerHashmark)
            ////
            //            }
            
        }
    }
    
    private func drawHashmarksInRect(context: CGContext, bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat)
    {
        let fixedOrigin = origin
        //we have fix bounds , if the origin is more than bounds then the hashmark will not be drawn
        if ((fixedOrigin.x >= bounds.minX) && (fixedOrigin.x <= bounds.maxX)) || ((fixedOrigin.y >= bounds.minY) && (fixedOrigin.y <= bounds.maxY))
        {
            // figure out how many units each hashmark must represent
            // to respect both pointsPerUnit and minimumPointsPerHashmark
            var unitsPerHashmark = pointsPerUnit / pointsPerUnit
            
            if unitsPerHashmark < 1 {
                unitsPerHashmark = pow(10, ceil(log10(unitsPerHashmark)))
            } else {
                unitsPerHashmark = floor(unitsPerHashmark)
            }
            
            
            let pointsPerHashmark = pointsPerUnit * unitsPerHashmark
            //usually equals to pointsPerUnit
            
            // figure out which is the closest set of hashmarks (radiating out from the origin) that are in bounds
            var startingHashmarkRadius: CGFloat = 1
            if !CGRectContainsPoint(bounds, fixedOrigin) {
                if fixedOrigin.x > bounds.maxX {
                    startingHashmarkRadius = (fixedOrigin.x - bounds.maxX) / pointsPerHashmark + 1
                } else if fixedOrigin.x < bounds.minX {
                    startingHashmarkRadius = (bounds.minX - fixedOrigin.x) / pointsPerHashmark + 1
                } else if fixedOrigin.y > bounds.maxY {
                    startingHashmarkRadius = (fixedOrigin.y - bounds.maxY) / pointsPerHashmark + 1
                } else {
                    startingHashmarkRadius = (bounds.minY - fixedOrigin.y) / pointsPerHashmark + 1
                }
                startingHashmarkRadius = floor(startingHashmarkRadius)
            }
            
            // now create a bounding box inside whose edges those four hashmarks lie
            let bboxSize = pointsPerHashmark * startingHashmarkRadius * 2
            var bbox = CGRect(center: origin, size: CGSize(width: bboxSize, height: bboxSize))
            
            // formatter for the hashmark labels
            let formatter = NSNumberFormatter()
            formatter.maximumFractionDigits = Int(-log10(Double(unitsPerHashmark)))
            formatter.minimumIntegerDigits = 1
            
            //causing failures when the origin goes out of bound
            //            for var i = 0; i < Int(ceil(bounds.width/(bboxSize/2))); i++ {
            var paddedBounds = bounds
            paddedBounds.origin.x = self.position.x
            while !CGRectContainsRect(bbox, paddedBounds)
            {
                
                let label = formatter.stringFromNumber((origin.x-bbox.minX)/pointsPerUnit)!
                
                if let leftHashMarkPoint = alignedPoint(x: bbox.minX, y: origin.y, insideBounds:paddedBounds) {
                    drawHashmarkAtLocation(context, location: leftHashMarkPoint, .Top("-\(label)"))
                }
                
                
                if let rightHashmarkPoint = alignedPoint(x: bbox.maxX, y: origin.y, insideBounds:paddedBounds) {
                    drawHashmarkAtLocation(context, location: rightHashmarkPoint, .Top(label))
                }
                
                bbox.insetInPlace(dx: -pointsPerHashmark, dy: -pointsPerHashmark)
            }
        }
    }
    
    
    private func drawHashmarkAtLocation(context: CGContext, location: CGPoint, _ text: AnchoredText)
    {
        var dx: CGFloat = 0, dy: CGFloat = 0
        switch text {
        case .Left: dx = Constants.HashmarkSize / 2
        case .Right: dx = Constants.HashmarkSize / 2
        case .Top: dy = Constants.HashmarkSize / 2
        case .Bottom: dy = Constants.HashmarkSize / 2
        }
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: location.x-dx, y: location.y-dy))
        path.addLineToPoint(CGPoint(x: location.x+dx, y: location.y+dy))
        
        CGContextBeginPath(context)
        CGContextAddPath(context, path.CGPath)
        CGContextStrokePath(context)
        
        if displayLabels {
            text.drawAnchoredToPoint(context, location: location, color: color)
        }
    }
    
    private enum AnchoredText
    {
        case Left(String)
        case Right(String)
        case Top(String)
        case Bottom(String)
        
        static let VerticalOffset: CGFloat = 3
        static let HorizontalOffset: CGFloat = 6
        
        func drawAnchoredToPoint(context: CGContext, location: CGPoint, color: UIColor) {
            let attributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(15),
                NSForegroundColorAttributeName : color
            ]
            var textRect = CGRect(center: location, size: text.sizeWithAttributes(attributes))
            switch self {
            case Top: textRect.origin.y -= textRect.size.height / 2 + AnchoredText.VerticalOffset
            case Left: textRect.origin.x -= textRect.size.width / 2 + AnchoredText.HorizontalOffset
            case Bottom: textRect.origin.y -= textRect.size.height / 2 + AnchoredText.VerticalOffset
            case Right: textRect.origin.x -= textRect.size.width / 2 + AnchoredText.HorizontalOffset
            }
            
            //Core text draw function
            let gString = NSMutableAttributedString(string:text, attributes:attributes)
            let line = CTLineCreateWithAttributedString(gString)
            
            CGContextSetTextPosition(context, textRect.origin.x, textRect.origin.y);
            CTLineDraw(line, context);
        }
        
        var text: String {
            switch self {
            case Left(let text): return text
            case Right(let text): return text
            case Top(let text): return text
            case Bottom(let text): return text
            }
        }
    }
    
    // we want the axes and hashmarks to be exactly on pixel boundaries so they look sharp
    // setting contentScaleFactor properly will enable us to put things on the closest pixel boundary
    // if contentScaleFactor is left to its default (1), then things will be on the nearest "point" boundary instead
    // the lines will still be sharp in that case, but might be a pixel (or more theoretically) off of where they should be
    
    private func alignedPoint(x x: CGFloat, y: CGFloat, insideBounds: CGRect? = nil) -> CGPoint?
    {
        let point = CGPoint(x: align(x), y: align(y))
        if let permissibleBounds = insideBounds {
            if (!CGRectContainsPoint(permissibleBounds, point)) {
                return nil
            }
        }
        return point
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * contentScaleFactor) / contentScaleFactor
    }
}

