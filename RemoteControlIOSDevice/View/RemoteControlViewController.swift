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
    
    @IBOutlet weak var refreshButton: NSButton!
    @IBOutlet weak var connectButton: NSButton!
    
    var viewModel : RemoteControlViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = RemoteControlViewModel(withViewController: self)
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
    
    @IBAction func connectToAppiumServer(_ sender: NSButton) {
        viewModel.connectToAppiumServer(completionHandler:
            {
            connectButton.isEnabled = false
            refreshButton.isEnabled = true
            
            self.refresh(NSButton())
        }){ [weak self] (text) in
            self?.showError(text: text)
            self?.connectButton.isEnabled = true
            self?.refreshButton.isEnabled = false
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

