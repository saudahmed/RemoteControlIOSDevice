//
//  RemoteControlModel.swift
//  RemoteControlIOSDevice
//
//  Created by Saud Ahmed on 17.05.18.
//  Copyright © 2018 privateprojects. All rights reserved.
//

import Foundation

enum AppiumPlatform
{
    case AppiumiOSPlatform
    case AppiumAndroidPlatform
}

class RemoteControlModel
{
    static let sharedInstance = RemoteControlModel()
    
    var serverProcess: Process?
    var iOSModel : RemoteControlIOSModel?
    var isServerRunning = false
    
    private init() {
        
        // initialize settings
        if let filePath = Bundle.main.path(forResource: "defaults", ofType: "plist")
        {
            if let settingsDict = NSDictionary(contentsOfFile: filePath) as? [String : Any]
            {
                UserDefaults.standard.register(defaults: settingsDict)
            }
        }
        
        // create ios model
        self.iOSModel = RemoteControlIOSModel()
    }
}
