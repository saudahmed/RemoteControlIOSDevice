//
//  RemoteControlModel.swift
//  RemoteControlIOSDevice
//
//  Created by Saud Ahmed on 17.05.18.
//  Copyright © 2018 privateprojects. All rights reserved.
//

import Foundation

struct RemoteControlModel
{
    var serverProcess: Process?
    var iOSModel : RemoteControlIOSModel?
    var isServerRunning = false
    
    init() {
        
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
    
    mutating func killServer() -> Bool
    {
        if let process = self.serverProcess
        {
            if process.isRunning
            {
            
                process.terminate()
                self.isServerRunning = false
                return true;
            }
        }
        
        return false;
    }
    
    mutating func startServer() -> Bool
    {
        if self.killServer()
        {
            return false;
        }
    
    
        var arguments = Array<ServerArgument>()
        var command = "'\(Bundle.main.resourcePath!)/node/bin/node' appium/build/lib/main.js"
        
        
        arguments.append(ServerArgument.argumentWith(name: "--platform-version",
                                                     value: (self.iOSModel?.platformVersion())!))
        
        arguments.append(ServerArgument.argumentWith(name: "--platform-name",
                                                     value: "iOS"))
        
        arguments.append(ServerArgument.argumentWith(name: "--app",
                                                     value: (self.iOSModel?.appPath())!))
        
        arguments.append(ServerArgument.argumentWith(name: "--udid",
                                                     value: (self.iOSModel?.udid())!))
        
        arguments.append(ServerArgument.argumentWith(name: "--full-reset"))
        
        arguments.append(ServerArgument.argumentWith(name: "--device-name",
                                                     value: (self.iOSModel?.deviceName())!))
    
        for argument in arguments
        {
            if let value = argument.value
            {
                command = command + " \(argument.name!) \"\(value)\""
            }
            else
            {
                command = command + " \(argument.name!)"
            }
        }
    
    
        self.setupServerProcess(commandString: command)
    
        // launch
        self.serverProcess?.launch()
        
        self.isServerRunning = (self.serverProcess?.isRunning)!
    
        return self.isServerRunning;
    }
    
    mutating func setupServerProcess(commandString: String)
    {
        var command = commandString
        
        self.serverProcess = Process()
        
        self.serverProcess?.currentDirectoryPath =  String(format: "%@/%@", Bundle.main.resourcePath!, "node_modules")
        
        // Add a cd call to the start of the command in case the .bash_profile or .bashrc changes the current directory
        command = String(format: "cd \"%@\" ; %@", (self.serverProcess?.currentDirectoryPath)!, command)
        
        self.serverProcess?.launchPath = "/bin/bash"
        
        self.serverProcess?.arguments = ["-l", "-c", commandString];
    
        // Redirect I/O
        self.serverProcess?.standardOutput = Pipe.init()
        self.serverProcess?.standardError = Pipe.init()
        self.serverProcess?.standardInput = Pipe.init()
    }
}
