//
//  ServerArgument.swift
//  RemoteControlIOSDevice
//
//  Created by Saud Ahmed on 17.05.18.
//  Copyright © 2018 privateprojects. All rights reserved.
//

import Foundation

struct ServerArgument
{
    var name : String?
    var value: String?
    
    static func argumentWith(name : String) -> ServerArgument
    {
        return ServerArgument(name: name, value: nil)
    }
    
    static func argumentWith(name : String, value: String) -> ServerArgument
    {
        return ServerArgument(name: name, value: value)
    }
}
