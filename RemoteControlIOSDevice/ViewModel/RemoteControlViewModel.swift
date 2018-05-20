//
//  RemoteControlViewModel.swift
//  RemoteControlIOSDevice
//
//  Created by Saud Ahmed on 18.05.18.
//  Copyright © 2018 privateprojects. All rights reserved.
//

import Foundation

class RemoteControlViewModel
{
    var model = RemoteControlModel.sharedInstance
    var driver : SERemoteWebDriver!
    
    var lastPageSource : String
    var orientation : SEScreenOrientation
    var rootNode: WebDriverElementNode!
    var browserRootNode : WebDriverElementNode!
    weak var viewController : RemoteControlViewController?
    
    var selection: WebDriverElementNode!
    var selectedIndexes: Array<Any>? = nil
    
    init(withViewController remoteViewController : RemoteControlViewController)
    {
        viewController = remoteViewController
        lastPageSource = ""
        orientation = SELENIUM_SCREEN_ORIENTATION_PORTRAIT
    }
    
    func connectToAppiumServer(errorHandler: @escaping (String) -> Void)
    {
        driver = SERemoteWebDriver(serverAddress: model.iOSModel?.serverAddress(), port: model.iOSModel?.serverPort() as! Int)
        
        if driver == nil
        {
            errorHandler("Could not connect to Appium Server")
        }
        
        let sessions = self.driver.allSessions
        
        if (self.driver == nil || sessions == nil)
        {
            return errorHandler("Could not get list of sessions from Appium Server");
        }
        
        // get session to use
        if ((sessions?.count)! > 0)
        {
            // use the existing session
            if let session = sessions?[0]
            {
                self.driver.session = session as! SESession
                
                if (self.driver == nil || self.driver.session == nil)
                {
                    return errorHandler("Could not set the session");
                }
            }
        }
        
        if (sessions?.count == 0 || self.driver.session == nil || self.driver.session.capabilities.platform == nil)
        {
            // create a new session if one does not already exist
            let capabilities = SECapabilities()
            
            capabilities.addCapability(forKey: "automationName", andValue: "Appium")
            capabilities.addCapability(forKey: "platformName", andValue: model.iOSModel?.platformName())
            capabilities.addCapability(forKey: "platformVersion", andValue: model.iOSModel?.platformVersion())
            capabilities.addCapability(forKey: "deviceName", andValue: model.iOSModel?.deviceName());
            capabilities.addCapability(forKey: "app", andValue: model.iOSModel?.appPath())
            capabilities.addCapability(forKey: "udid", andValue:model.iOSModel?.udid());
            
            self.driver.startSession(withDesiredCapabilities: capabilities, requiredCapabilities: nil)
        }
    }
    
    //MARK: Tree Operations
    func populateDOM()
    {
        self.refreshPageSource()
        self.refreshOrientation()
        self.refreshScreenshot()
        
        do {
            var jsonDict = try XMLReader.dictionary(forXMLString: lastPageSource) as NSDictionary
            
            self.rootNode = WebDriverElementNode(jsonDict: &jsonDict, parent: nil, showDisabled: true, showInvisible: true)
            
            self.selection = nil
            self.selectedIndexes = nil
            self.selectedIndexes = Array<Any>()
            
            DispatchQueue.main.sync { [unowned self] in
                self.updateDetailsDisplay()
            }
        } catch {
            
        }
    }
    
    func refreshPageSource()
    {
        if let lastPageSource = self.driver.pageSource
        {
            self.lastPageSource = lastPageSource
        }
    }
    
    func refreshOrientation()
    {
        orientation = self.driver.orientation
        
        switch (orientation)
        {
        case SELENIUM_SCREEN_ORIENTATION_PORTRAIT:
            viewController?.screenShotImageView.rotation = 0
        case SELENIUM_SCREEN_ORIENTATION_LANDSCAPE:
            viewController?.screenShotImageView.rotation = 90;
        default:
            print("unknown")
        }
    }
    
    func refreshScreenshot()
    {
        if let screenshot = self.driver.screenshot
        {
            viewController?.screenShotImageView.setImage(newImage: screenshot)
        }
    }
    
    func findDisplayedNodeForPoint(_ point: NSPoint, node: WebDriverElementNode) -> WebDriverElementNode?
    {
        // DFS for element inside rect
        for child in node.visibleChildren
        {
            if let child = child as? WebDriverElementNode
            {
                if let result = self.findDisplayedNodeForPoint(point, node:child)
                {
                    return result
                }
            }
        }
        
        if NSPointInRect(point, node.rect) && !(node.type == "UIAWindow")
        {
            return node;
        }
        
        return nil
    }
    
    func setSelectedNode(_ node: WebDriverElementNode)
    {
        // get the tree from the node to the root
        var nodes = Array<Any>()
        var currentNode = node
        
        nodes.append(currentNode);
        
        while(currentNode.parent != nil)
        {
            currentNode = currentNode.parent!
            nodes.append(currentNode)
        }
        
        // get the indexes from the root to the node
        var nodePath = Array<Any>()
        
        for i in stride(from: nodes.count-1, to: 0, by: -1)
        {
            currentNode = nodes[i] as! WebDriverElementNode
            
            let nodeToFind = nodes[i-1] as! WebDriverElementNode
            
            let foundNode = false
            
            if (!foundNode)
            {
                for j in stride(from: 0, to: currentNode.visibleChildren.count, by: 1)
                {
                    if let child = currentNode.visibleChildren[j] as? WebDriverElementNode
                    {
                        if child == nodeToFind
                        {
                            nodePath.append(NSNumber(value: j))
                        }
                    }
                }
            }
        }
        
        // build index set
        var indexPath = NSIndexPath()
        
        for i in stride(from: 0, to: nodePath.count, by: 1)
        {
            indexPath = indexPath.adding((nodePath[i] as? NSNumber)!.intValue) as NSIndexPath
            
            if ((self.selectedIndexes?.count)! < i+1)
            {
                self.selectedIndexes?.append(NSNumber(value:(nodePath[i] as? NSNumber)!.intValue))
            }
            else
            {
                self.selectedIndexes?[i] = (nodePath[i] as? NSNumber)!
            }
        }
        
        // select
        self.selection = node;
        self.updateDetailsDisplay()
    }
    
    func selectNodeNearestPoint(_ point: NSPoint)
    {
        if let node = self.findDisplayedNodeForPoint(point, node: self.rootNode)
        {
            self.setSelectedNode(node)
        }
    }
    
    func xPathForSelectedNode() -> String
    {
        var parentNode = self.rootNode
        
        var xPath = "/"
        var foundNode = false
        
        if (!foundNode)
        {
            if let count = self.selectedIndexes?.count
            {
                for i in stride(from: 0, to: count, by: 1)
                {
                    // find current node
                    let currentNode = parentNode?.visibleChildren[(self.selectedIndexes?[i] as! NSNumber).intValue]  as? WebDriverElementNode
                    if currentNode == self.selection{
                        foundNode = true
                    }
                    
                    // build xpath
                    xPath = xPath + "/"
                    xPath = xPath + (currentNode?.type)!
                    
                    var nodeTypeCount = 0
                    
                    if let size = parentNode?.children.count
                    {
                        for j in stride(from: 0, to: size, by: 1)
                        {
                            let node = parentNode?.children[j] as? WebDriverElementNode
                            var selectedNodeAtLevel = self.rootNode
                            
                            var k = 0
                            while k < (self.selectedIndexes?.count)! && k <= i
                            {
                                let index = self.selectedIndexes?[k] as! NSNumber
                                selectedNodeAtLevel = selectedNodeAtLevel?.visibleChildren[index.intValue] as? WebDriverElementNode
                                k = k + 1
                            }
                            
                            if node?.type == selectedNodeAtLevel?.type
                            {
                                nodeTypeCount = nodeTypeCount + 1
                            }
                            
                            if (node == selectedNodeAtLevel)
                            {
                                break
                            }
                        }
                    }
                    xPath = xPath + "[\(nodeTypeCount)]"
                    parentNode = currentNode
                }
            }
        }
        return xPath
    }
    
    func selectedNodeNameIsUniqueInTree(_ node: WebDriverElementNode) -> Bool
    {
        if node == self.selection
        {
            if node.name == ""
            {
                return false
            }
        }
        else
        {
            if node.name != ""
            {
                if node.name == self.selection.name
                {
                    return false
                }
            }
        }
        
        for i in stride(from: 0, to: node.children.count, by: 1)
        {
            if !self.selectedNodeNameIsUniqueInTree(node.children[i] as! WebDriverElementNode)
            {
                return false
            }
        }
        
        return true
    }
    
    func locatorForSelectedNode() -> AppiumCodeMakerLocator
    {
        let xPath = self.xPathForSelectedNode()
        if self.selectedNodeNameIsUniqueInTree(self.rootNode)
        {
            return AppiumCodeMakerLocator(locatorType: AppiumCodeMakerLocatorType.APPIUM_CODE_MAKER_LOCATOR_TYPE_NAME,
                                          locatorString: self.selection.name,
                                          xPath: xPath)
        }
        else
        {
            return AppiumCodeMakerLocator(locatorType: AppiumCodeMakerLocatorType.APPIUM_CODE_MAKER_LOCATOR_TYPE_XPATH,
                                          locatorString: xPath,
                                          xPath: xPath)
        }
    }
    
    //MARK: Highlight
    func updateDetailsDisplay()
    {
        if let highlightView = viewController?.selectedElementHighlightView
        {
            if let _ = self.selection, let layer = highlightView.layer
            {
                highlightView.wantsLayer = true
                layer.borderWidth = 2.0
                layer.cornerRadius = 8.0
                
                let redColor = NSColor.red
                let redCGColor = redColor.cgColor
                layer.borderColor = redCGColor
                
                let viewRect = viewController?.screenShotImageView.convertSeleniumRectToViewRect(rect: self.selection.rect)
                highlightView.frame = viewRect!
                highlightView.isHidden = false
            }
            else
            {
                highlightView.isHidden = true
            }
        }
    }
    
    //MARK: Handle click
    func handleClickAt(windowPoint: NSPoint, WithSeleniumPoint seleniumPoint: NSPoint)
    {
        self.selectNodeNearestPoint(seleniumPoint)
    }
}

