//
//  MyView.swift
//  RectangleDetect
//
//  Created by Friedrich HAEUPL on 30.01.17.
//  Copyright © 2017 Friedrich HAEUPL. All rights reserved.
//

import Cocoa

// https://forums.developer.apple.com/thread/56394
// http://stackoverflow.com/questions/40021560/can-cidetector-returns-more-than-one-cifeature-of-type-cidetectortyperectangle
// http://howtoprogram.eu/question/represent-cirectanglefeature-with-uibezierpath--swift,9763
//


class MyView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSLog("dirtyRect = \(dirtyRect)")
        
        // avoid optional unwrapping later :
        // 1
        guard let fileURL = Bundle.main.url(forResource: "rect1", withExtension: "png")
            else
        {
            NSLog("ciImage doesn't exist")
            return
        }
        // 2
        guard let ciImage = CIImage(contentsOf: fileURL)
            else
        {
            NSLog("ciImage not loaded")
            return
        }
        
        // 3    get size of the image
        let ciImageSize = ciImage.extent.size
        NSLog("ciImage extent \(ciImage.extent)")
        
        // 4    convert CIImage to NSImage
        let rep: NSCIImageRep = NSCIImageRep(ciImage: ciImage)
        let nsImage: NSImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        
        // 1) Just draw it
        // nsImage.drawAtPoint(NSZeroPoint, fromRect: NSZeroRect, operation:.CompositeSourceOver, fraction: 1)
        // 2) Or stretch image to fill view
        nsImage.draw(in: self.bounds, from:NSZeroRect ,operation:.sourceOver, fraction:1)
        
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        
        let rectDetector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)!
        
        let rects = rectDetector.features(in: ciImage)

        NSLog("Found \(rects.count) rectangles")
        
        for rect in rects as! [CIRectangleFeature] {
            
            NSLog("---------")
            NSLog("Found rect at \(rect.bounds) of \(rects.count) Faces")
            
            //
            var rectViewBounds = rect.bounds
            
            // Calculate the actual position and size of the rectangle in the image view
            let viewSize = dirtyRect.size
            //
            let scale_w = viewSize.width / (ciImageSize.width)
            let scale_h = viewSize.height / (ciImageSize.height)
            let offsetX = (viewSize.width - (ciImageSize.width) * scale_w) / 2.0
            let offsetY = (viewSize.height - (ciImageSize.height) * scale_h) / 2.0
            
            rectViewBounds = rectViewBounds.applying(CGAffineTransform(scaleX: scale_w, y: scale_h))
            rectViewBounds.origin.x += offsetX
            rectViewBounds.origin.y += offsetY
            NSLog("rectViewBounds is \(rectViewBounds)")
           
            NSColor.red.set()
            let path:NSBezierPath = NSBezierPath()
            path.appendRect(rectViewBounds)
            path.stroke()

        }


    }
    
}
