//
//  RemoteControlIOSModel.swift
//  RemoteControlIOSDevice
//
//  Created by Saud Ahmed on 17.05.18.
//  Copyright © 2018 privateprojects. All rights reserved.
//

import Foundation

enum UserDefaultKeys : String
{
    case platformVersion = "iOS Platform Version"
    case appPath = "iOS App Path"
    case udid = "iOS UDID"
    case deviceName = "iOS Device Name"
    case serverAddress = "Server Address"
    case serverPort = "Server Port"
}

struct RemoteControlIOSModel
{
    func platformVersion()-> String{
        return UserDefaults.standard.string(forKey: UserDefaultKeys.platformVersion.rawValue)!
    }
    
    func appPath()-> String{
        return UserDefaults.standard.string(forKey: UserDefaultKeys.appPath.rawValue)!
    }
    
    func udid()-> String{
        return UserDefaults.standard.string(forKey: UserDefaultKeys.udid.rawValue)!
    }
    
    func deviceName()-> String{
        return UserDefaults.standard.string(forKey: UserDefaultKeys.deviceName.rawValue)!
    }
    
    func serverAddress()-> String{
        return UserDefaults.standard.string(forKey: UserDefaultKeys.serverAddress.rawValue)!
    }
    
    func serverPort()-> NSNumber{
        return NSNumber(value: Int(UserDefaults.standard.string(forKey: UserDefaultKeys.serverPort.rawValue)!)!)
    }
    
    func platformName()-> String{
        return "iOS"
    }
}
