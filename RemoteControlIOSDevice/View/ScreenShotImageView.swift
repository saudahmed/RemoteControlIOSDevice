//
//  ScreenShotImageView.swift
//  RemoteControlIOSDevice
//
//  Created by Saud Ahmed on 18.05.18.
//  Copyright © 2018 privateprojects. All rights reserved.
//

import Cocoa

class ScreenShotImageView: NSImageView
{
    var originalImage : NSImage?
    weak var viewController : RemoteControlViewController?
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        originalImage = nil
        viewController = nil
    }
    
    var scalar : CGFloat
    {
        get
        {
            return fmin(self.bounds.size.width / (self.image?.size.width)!, self.bounds.size.height / (self.image?.size.height)!)
        }
    }
    
    var scalarMultiplier : CGFloat = 1.0
    
    var rotation : CGFloat = 0.0
    {
        didSet
        {
            self.setUpScreenshotView(newImage: self.originalImage)
        }
    }
    
    //MARK: Draw Image
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    func setImage(newImage: NSImage)
    {
        self.originalImage = newImage
        
        self.setUpScreenshotView(newImage: newImage)
    }
    
    func setUpScreenshotView(newImage : NSImage?)
    {
        if let newImage = newImage
        {
            DispatchQueue.main.async {
                super.image = self.rotateImage(image: newImage, byAngle: self.rotation)
                
                
                self.scalarMultiplier = 1.0
                
                // check for retina devices
                if (self.image?.size.width == 640 && self.image?.size.height == 960)
                {
                    // portrait 3.5" iphone with retina display
                    self.scalarMultiplier = 2.0
                }
                else if (self.image?.size.width == 960 && self.image?.size.height == 640)
                {
                    // landscape 3.5" iphone with retina display
                    self.scalarMultiplier = 2.0
                }
                else if (self.image?.size.width == 640 && self.image?.size.height == 1136)
                {
                    // portrait 4" iphone with retina display
                    self.scalarMultiplier = 2.0
                }
                else if (self.image?.size.width == 1136 && self.image?.size.height == 640)
                {
                    // landscape 4" iphone with retina display
                    self.scalarMultiplier = 2.0
                }
                else if (self.image?.size.width == 750 && self.image?.size.height == 1334)
                {
                    // portrait iphone 6
                    self.scalarMultiplier = 2.0
                }
                else if (self.image?.size.width == 1334 && self.image?.size.height == 750)
                {
                    // landscape iphone 6
                    self.scalarMultiplier = 2.0
                }
                else if (self.image?.size.width == 1242 && self.image?.size.height == 2208)
                {
                    // portrait iphone 6 plus
                    self.scalarMultiplier = 3.0
                }
                else if (self.image?.size.width == 2208 && self.image?.size.height == 1242)
                {
                    // landscape iphone 6 plus
                    self.scalarMultiplier = 3.0
                }
                else if (self.image?.size.width == 1536 && self.image?.size.height == 2048)
                {
                    // portrait ipad with retina display
                    self.scalarMultiplier = 2.0
                }
                else if (self.image?.size.width == 2048 && self.image?.size.height == 1536)
                {
                    // landscape ipad with retina display
                    self.scalarMultiplier = 2.0
                }
            }
        }
    }
    
    //MARK: Scaling
    func multipliedScalar(scalar: CGFloat)-> CGFloat
    {
        return scalar * self.scalarMultiplier
    }
    
    func offsetForScaledSize(scaled: CGSize) -> CGSize
    {
        let size = CGSize(width: (self.bounds.size.width - scaled.width) / 2,
                          height: (self.bounds.size.height - scaled.height) / 2)
        return size
    }
    
    func scaledImageSizeForScalar(scalar: CGFloat) -> CGSize
    {
        let size = CGSize(width: (self.image?.size.width)! * scalar,
                          height: (self.image?.size.height)! * scalar)
        return size
    }
    
    //MARK: Point Conversion
    func convertSeleniumPointToViewPoint(point: NSPoint) -> NSPoint
    {
        // Get the scalar value
        let scalar = self.scalar;
        
        // Calculate the multiplied scalar
        let multipliedScalar = self.multipliedScalar(scalar: scalar)
        
        // Calculate the scaled image size
        let scaled = self.scaledImageSizeForScalar(scalar: scalar)
        
        // Calculate the offset size
        let offset = self.offsetForScaledSize(scaled: scaled)
        
        // Create a new point
        var viewPoint = NSZeroPoint
        
        // Map the point onto the view using the offset and scalar
        viewPoint.x = offset.width + (point.x * multipliedScalar);
        viewPoint.y = (self.bounds.size.height - (point.y * multipliedScalar)) - offset.height;
        
        return viewPoint;
    }
    
    func convertSeleniumRectToViewRect(rect:NSRect) -> NSRect
    {
        // Get the scalar value
        let scalar = self.scalar;
        
        // Calculate the multiplied scalar
        let multipliedScalar = self.multipliedScalar(scalar: scalar)
        
        // Calculate the scaled image size
        let scaled = self.scaledImageSizeForScalar(scalar: scalar)
        
        // Calculate the offset size
        let offset = self.offsetForScaledSize(scaled: scaled)
        
        // Copy the provided rect
        var viewRect = rect;
        
        // Update the size using the scalar
        viewRect.size.width  *= multipliedScalar;
        viewRect.size.height *= multipliedScalar;
        
        // Update the origin
        viewRect.origin.x = offset.width + (rect.origin.x * multipliedScalar);
        viewRect.origin.y = (self.bounds.size.height - (rect.origin.y + rect.size.height) * multipliedScalar) - offset.height;
        
        return viewRect;
    }
    
    func convertWindowPointToSeleniumPoint(pointInWindow:NSPoint) -> NSPoint
    {
        // Get the scalar value
        let scalar = self.scalar;
        
        // Calculate the multiplied scalar
        let multipliedScalar = self.multipliedScalar(scalar: scalar)
        
        // Calculate the scaled image size
        let scaled = self.scaledImageSizeForScalar(scalar: scalar)
        
        // Calculate the offset size
        let offset = self.offsetForScaledSize(scaled: scaled)
        
        // Convert the point to the view
        let relativePoint = self.convert(pointInWindow, from: nil)
        
        // Create a new point
        var newPoint = NSZeroPoint;
        
        // Map the point onto the view using the offset and scalar
        newPoint.x = (relativePoint.x - offset.width) / multipliedScalar;
        newPoint.y = (self.bounds.size.height - (relativePoint.y + offset.height)) / multipliedScalar;
        
        return newPoint;
    }
    
    //MARK: Handle click
    override func mouseUp(with event: NSEvent) {
        let point = event.locationInWindow
        
        // Update the values used when drawing layers in case the image frame changed
        if (self.image != nil)
        {
            self.setUpScreenshotView(newImage: nil)
        }
        
        viewController?.viewModel.handleClickAt(windowPoint: point, WithSeleniumPoint: self.convertWindowPointToSeleniumPoint(pointInWindow: point))
        
        self.tap()
        
        self.setNeedsDisplay()
    }
    
    //MARK: Perform Tap
    func tap()
    {
        let locator = viewController?.viewModel.locatorForSelectedNode()
        
        let action = AppiumCodeMakerActionTap(withLocator: locator!)
        
        action.block((viewController?.viewModel.driver)!);
        
        viewController?.refresh(NSButton())
    }
    
    //MARK: Rotation
    func rotateImage(image: NSImage, byAngle degrees : CGFloat) -> NSImage
    {
        if (degrees == 0)
        {
            return image
        }
        
        let beforeSize = image.size
        let afterSize = degrees == 90 || degrees == 270 ? NSMakeSize(beforeSize.height, beforeSize.width) : beforeSize;
        
        let newImage = NSImage(size: afterSize)
        
        let trans = NSAffineTransform()
        trans.rotate(byDegrees: degrees)
        
        let center = NSAffineTransform()
        center.translateX(by: afterSize.width / 2.0, yBy: afterSize.height / 2.0)
        
        trans.append(center as AffineTransform)
        
        newImage.lockFocus()
        
        trans.concat()
        
        let rect = NSMakeRect(0, 0, beforeSize.width, beforeSize.height)
        let corner = NSMakePoint(-beforeSize.width / 2.0, -beforeSize.height / 2.0)
        
        image.draw(at: corner, from: rect, operation: NSCompositingOperation.copy, fraction: 1.0)
        
        newImage.unlockFocus()
        
        return newImage
    }
}
