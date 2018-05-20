# RemoteControlIOSDevice

- Follow this guide to setup appium server on your system
http://appium.io/docs/en/about-appium/getting-started/index.html

- Applium client library used is written in Objective - C and is added as dependency using cocoapods
https://github.com/appium/selenium-objective-c

- Appium's primary support for automating iOS apps is via the XCUITest driver.
http://appium.io/docs/en/drivers/ios-xcuitest/#the-xcuitest-driver-for-ios

- Automating a real device with XCUITest is considerably more complicated, follow the link here. Application will not automate on real device unless web driver agent app is installed.
http://appium.io/docs/en/drivers/ios-xcuitest/#real-device-setup

- Following paramaters must be updated in defaults.plist under RemoteControlIOSDevice/SupportingFiles/defaults.plist 

# Parameters
Set them under RemoteControlIOSDevice/SupportingFiles/defaults.plist

- "iOS Platform Version"  - currently set to "11.1.2"
- "iOS App Path"          - currently set to "/Users/saudahmed/Desktop/Zizzle/IntegrationApp.app"
- "iOS UDID"              - currently set to "5be4be2eae555016cc5ec8113c84fba80ec3d7e4"
- "iOS Device Name"       - currently set to "iPhone 6"

IntegrationApp.app is taken from WebDriverAgent Repository

# Points to run system
- First run the appium server using command in terminal $ appium
- Let appium server to run
- Build the code using xcode and run on connected iOS device. This iOS device details must be set according to Parameters section.
- UDID and other details can be picked using "Window/Device and Simulators" inside Xcode. This can be selected using Xcode menu bar. 
- The Mac app will pop up and press "Connect to appium server" inside the window.
- Once connection is established, Screen shot of the installed app will appear inside the window.
- Press refresh button to take screen shot
- Click on screen shot to interact with application installed on device or on simulator.
- Only installed application can be interacted with.

There are are two ways to run application
# App path
To run with app path, uncomment under file RemoteControlViewModel.swift 

- capabilities.addCapability(forKey: "app", andValue: model.appPath())
- //capabilities.addCapability(forKey: "bundleId", andValue: "com.zizzlellc.powzzle")

# Bundle id
To run with bundle id, uncomment under file RemoteControlViewModel.swift. Bundle id can be set of any previously installed application on device.

- //capabilities.addCapability(forKey: "app", andValue: model.appPath())
- capabilities.addCapability(forKey: "bundleId", andValue: "com.zizzlellc.powzzle")

