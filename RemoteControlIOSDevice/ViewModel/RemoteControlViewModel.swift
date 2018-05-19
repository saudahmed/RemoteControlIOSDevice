//
//  RemoteControlViewModel.swift
//  RemoteControlIOSDevice
//
//  Created by Saud Ahmed on 18.05.18.
//  Copyright © 2018 privateprojects. All rights reserved.
//

import Foundation

struct RemoteControlViewModel
{
    var model = RemoteControlModel.sharedInstance
    var driver : SERemoteWebDriver!
    
    var lastPageSource : String
    var orientation : SEScreenOrientation
    var rootNode: WebDriverElementNode!
    var browserRootNode : WebDriverElementNode!
    weak var viewController : RemoteControlViewController?
    
    init(withViewController remoteViewController : RemoteControlViewController)
    {
        viewController = remoteViewController
        lastPageSource = ""
        orientation = SELENIUM_SCREEN_ORIENTATION_PORTRAIT
    }
    
    mutating func connectToAppiumServer(errorHandler: @escaping (String) -> Void)
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
    mutating func populateDOM()
    {
        var e : NSError? = nil;
        
        self.refreshPageSource()
        self.refreshOrientation()
        self.refreshScreenshot()

//        do {
//            let jsonDict = try XMLReader.dictionary(forXMLString: lastPageSource)
////            browserRootNode = WebDriverElementNode(
////            
////            
////            [[WebDriverElementNode alloc] initWithJSONDict:jsonDict parent:nil showDisabled:[self.showDisabled boolValue] showInvisible:[self.showInvisible boolValue]];
////            _rootNode = [[WebDriverElementNode alloc] initWithJSONDict:jsonDict parent:nil showDisabled:[self.showDisabled boolValue] showInvisible:[self.showInvisible boolValue]];
////            [_windowController.browser performSelectorOnMainThread:@selector(loadColumnZero) withObject:nil waitUntilDone:YES];
////            _selection = nil;
////            _selectedIndexes = [NSMutableArray new];
////            [self performSelectorOnMainThread:@selector(updateDetailsDisplay) withObject:nil waitUntilDone:YES];
////            [self performSelectorOnMainThread:@selector(setDomIsPopulatingToNo) withObject:nil waitUntilDone:YES];
//            
//        } catch {
//            
//        }
    }
    
    mutating func refreshPageSource()
    {
        lastPageSource = self.driver.pageSource
    }
    
    mutating func refreshOrientation()
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
    
    func handleClickAt(windowPoint: NSPoint, WithSeleniumPoint seleniumPoint: NSPoint)
    {
        //self.selectNodeNearestPoint(seleniumPoint)
    }
}
