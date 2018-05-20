//
//  AppiumCodeMakerActionTap.swift
//  RemoteControlIOSDevice
//
//  Created by Saud Ahmed on 20.05.18.
//  Copyright © 2018 privateprojects. All rights reserved.
//

import Foundation

enum AppiumCodeMakerActionType
{
    case APPIUM_CODE_MAKER_ACTION_ALERT_ACCEPT
    case APPIUM_CODE_MAKER_ACTION_ALERT_DISMISS
    case APPIUM_CODE_MAKER_ACTION_COMMENT
    case APPIUM_CODE_MAKER_ACTION_EXECUTE_SCRIPT
    case APPIUM_CODE_MAKER_ACTION_PRECISE_TAP
    case APPIUM_CODE_MAKER_ACTION_SCROLL_TO
    case APPIUM_CODE_MAKER_ACTION_SEND_KEYS
    case APPIUM_CODE_MAKER_ACTION_SHAKE
    case APPIUM_CODE_MAKER_ACTION_SWIPE
    case APPIUM_CODE_MAKER_ACTION_TAP
}

class AppiumCodeMakerActionTap
{
    var actionType : AppiumCodeMakerActionType
    var params = Dictionary<String, AppiumCodeMakerLocator>()
    
    init(withLocator locator : AppiumCodeMakerLocator)
    {
        self.actionType = AppiumCodeMakerActionType.APPIUM_CODE_MAKER_ACTION_TAP;
        self.params["locator"] = locator
    }
    
    var locator : AppiumCodeMakerLocator
    {
        return params["locator"]!
    }
    
    var block : (SERemoteWebDriver) -> Void
    {
        return {(driver) -> Void in
            let element = driver.findElement(self.locator.by)
            element?.click()
        }
    }
}
