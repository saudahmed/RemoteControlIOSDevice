//
//  ViewController.swift
//  RemoteControlIOSDevice
//
//  Created by Saud Ahmed on 15.05.18.
//  Copyright © 2018 privateprojects. All rights reserved.
//

import Cocoa

class RemoteControlViewController: NSViewController {
    
    @IBOutlet weak var screenShotImageView: ScreenShotImageView!
    {
        didSet
        {
            screenShotImageView.viewController = self
        }
    }
    
    @IBOutlet weak var selectedElementHighlightView: NSView!
    
    var viewModel : RemoteControlViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = RemoteControlViewModel(withViewController: self)
        
        viewModel.connectToAppiumServer(){ (text) in
            self.showError(text: text)
        }
        
        //viewModel.populateDOM()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func refresh(_ sender: NSButton) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.viewModel.populateDOM()
        }
    }
    
    func showError(text: String)
    {
        OperationQueue.main.addOperation{
            let alert = NSAlert()
            alert.messageText = "Could not connect to Appium Server"
            alert.informativeText = String(format: "%@\n\n%@", text, "Be sure the Appium server is running with an application opened by using the \"App Path\" parameter in Appium.app (along with package and activity for Android) or by connecting with selenium client and supplying this in the desired capabilities object.")
            
            alert.runModal()
        }
    }
}

