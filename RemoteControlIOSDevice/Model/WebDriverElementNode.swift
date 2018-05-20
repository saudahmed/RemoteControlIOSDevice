//
//  WebDriverElementNode.swift
//  RemoteControlIOSDevice
//
//  Created by Saud Ahmed on 18.05.18.
//  Copyright © 2018 privateprojects. All rights reserved.
//

import Foundation

class WebDriverElementNode : NSObject
{
    var jsonDict : NSDictionary
    var children : Array<Any>
    var visibleChildren : Array<Any>
    var showDisabled : Bool
    var showInvisible: Bool
    var parent : WebDriverElementNode?
    var platform : AppiumPlatform
    var enabled : Bool = false
    var visible : Bool = false
    var valid : Bool  = false
    var label : String = ""
    var hint : String = ""
    var type : String = ""
    var path : String = ""
    var value : String = ""
    var name : String = ""
    var rect : NSRect
    
    var isLeaf : Bool
    {
        return self.children.count < 1
    }
    
    var shouldDisplay : Bool
    {
        if (self.showInvisible || self.visible || self.platform == AppiumPlatform.AppiumAndroidPlatform) && (self.showDisabled || self.enabled)
        {
            return true;
        }
        
        if self.isLeaf
        {
            return false;
        }
        
        for visibleChild in self.visibleChildren
        {
            if ((visibleChild as? WebDriverElementNode)?.shouldDisplay)!
            {
                return true
            }
        }
        
        return false
    }
    
    init(jsonDict : inout NSDictionary, parent : WebDriverElementNode?, showDisabled : Bool, showInvisible: Bool)
    {
        
        while(jsonDict.object(forKey: "hierarchy") != nil || "hierarchy" == (jsonDict.object(forKey: "tag") as? String))
        {
            
            jsonDict = ((jsonDict.object(forKey: "children") as! Array<Any>)[0] as? NSDictionary)!
        }
        
        self.jsonDict = jsonDict
        print(jsonDict)
        
        self.showDisabled = showDisabled;
        self.showInvisible = showInvisible;
        
        self.parent = parent
        
        // iOS Node
        self.platform = AppiumPlatform.AppiumiOSPlatform
        if let value = self.jsonDict.object(forKey: "enabled")
        {
            self.enabled = (value as! NSString).boolValue
        }
        
        if let value = self.jsonDict.object(forKey: "visible")
        {
            self.visible = (value as! NSString).boolValue
        }
        
        if let value = self.jsonDict.object(forKey: "valid")
        {
            self.valid = (value as! NSString).boolValue
        }
        
        if let value = self.jsonDict.object(forKey: "label")
        {
            self.label = value as! String
        }
        
        if let value = self.jsonDict.object(forKey: "hint")
        {
            self.hint = value as! String
        }
        
        if let value = self.jsonDict.object(forKey: "tag")
        {
            self.type = value as! String
        }
        
        if let value = self.jsonDict.object(forKey: "path")
        {
            self.path = value as! String
        }
        
        if let value = self.jsonDict.object(forKey: "value")
        {
            self.value = value as! String
        }
        
        if let value = self.jsonDict.object(forKey: "name")
        {
            self.name = value as! String
        }
        
        var x : CGFloat = 0.0
        if let value = self.jsonDict.object(forKey: "x")
        {
            x = CGFloat((value as! NSString).floatValue)
        }
        
        var y : CGFloat = 0.0
        if let value = self.jsonDict.object(forKey: "y")
        {
            y = CGFloat((value as! NSString).floatValue)
        }
        
        var width : CGFloat = 0.0
        if let value = self.jsonDict.object(forKey: "width")
        {
            width = CGFloat((value as! NSString).floatValue)
        }
        
        var height : CGFloat = 0.0
        if let value = self.jsonDict.object(forKey: "height")
        {
            height = CGFloat((value as! NSString).floatValue)
        }
        
        self.rect = NSMakeRect(x, y, width, height)

        self.children = Array<Any>()
        self.visibleChildren = Array<Any>()
        
        super.init()
        
        let jsonItems = (self.jsonDict.object(forKey: "children") as? Array<Any>)!
        
        for jsonItem in jsonItems
        {
            if var jsonItem = jsonItem as? NSDictionary
            {
                let child = WebDriverElementNode(jsonDict: &jsonItem, parent: self, showDisabled: self.showDisabled, showInvisible: self.showInvisible)
            
            self.children.append(child)
            
            if child.shouldDisplay
            {
                self.visibleChildren.append(child)
            }
            }
        }
    }
}
