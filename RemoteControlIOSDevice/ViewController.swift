//
//  ViewController.swift
//  RemoteControlIOSDevice
//
//  Created by Saud Ahmed on 15.05.18.
//  Copyright © 2018 privateprojects. All rights reserved.
//

import Cocoa
import SocketIO

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var model = RemoteControlModel()
        model.startServer()
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

