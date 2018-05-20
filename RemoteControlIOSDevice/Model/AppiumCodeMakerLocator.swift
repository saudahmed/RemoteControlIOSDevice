//
//  AppiumCodeMakerLocator.swift
//  RemoteControlIOSDevice
//
//  Created by Saud Ahmed on 19.05.18.
//  Copyright © 2018 privateprojects. All rights reserved.
//

import Foundation

enum AppiumCodeMakerLocatorType
{
    case APPIUM_CODE_MAKER_LOCATOR_TYPE_REFERENCE
    case APPIUM_CODE_MAKER_LOCATOR_TYPE_NAME
    case APPIUM_CODE_MAKER_LOCATOR_TYPE_XPATH
}

struct AppiumCodeMakerLocator
{
    var locatorType : AppiumCodeMakerLocatorType
    var locatorString : String
    var xPath : String
    
    var by : SEBy?
    {
        if (UserDefaults.standard.bool(forKey: "Inspector Uses XPath Only"))
        {
            return self.byXPath
        }
    
        switch(self.locatorType)
        {
            case AppiumCodeMakerLocatorType.APPIUM_CODE_MAKER_LOCATOR_TYPE_NAME:
                return SEBy.name(self.locatorString)
            case AppiumCodeMakerLocatorType.APPIUM_CODE_MAKER_LOCATOR_TYPE_XPATH:
                return SEBy.xPath(self.xPath)
            default:
                return nil;
        }
    }
    
    var byXPath : SEBy
    {
        return SEBy.xPath(self.xPath)
    }
}
