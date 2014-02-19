PSUpdateApp
===========

## PSUpdateApp Version 2.0 is available!!!
The new version 2.0 is based on **[AFNetworking](https://github.com/AFNetworking/AFNetworking/ "AFNetworking")** framework 2.0. AFNetworking 2.0 officially supports iOS 6+, Mac OS X 10.8+, and Xcode 5.

**If you'd like to use PSUpdateApp in a project targeting a base SDK of iOS 5, or Mac OS X 10.7, use the latest tagged 1.x release**.

## A simple method to notify users that a new version of your iOS app is available.

### About
**PSUpdateApp** notifies you if a new version of your iOS application is available in the AppStore or in any other place.<br />
If a new version is available, PSUpdateApp presents an UIAlertView, that informs you of the newer version, and gives you the option to update the application.<br />
The component is based on **[AFNetworking](https://github.com/AFNetworking/AFNetworking/ "AFNetworking")** framework, using [`AFJSONRequestOperation`](http://afnetworking.github.com/AFNetworking/Classes/AFJSONRequestOperation.html) method to read and parse the JSON response.<br />

##Getting Started

### Installation

The recommended approach for installating PSUpdateApp is via the [CocoaPods](http://cocoapods.org/) package manager, as it provides flexible dependency management and dead simple installation. For best results, it is recommended that you install via CocoaPods **>= 0.16.0** using Git **>= 1.8.0** installed via Homebrew.

#### via CocoaPods

Install CocoaPods if not already available:

``` bash
$ [sudo] gem install cocoapods
$ pod setup
```

Change to the directory of your Xcode project, and Create and Edit your Podfile and add PSUpdateApp:

``` bash
$ cd /path/to/MyProject
$ touch Podfile
$ edit Podfile
platform :ios, '6.0' 
# Or platform :osx, '10.8'
pod 'PSUpdateApp', '~> 2.0.4'
```

Install into your project:

``` bash
$ pod install
```

Open your project in Xcode from the .xcworkspace file (not the usual project file)

``` bash
$ open MyProject.xcworkspace
```

#### via Download

[Download PSUpdateApp](https://github.com/danielebogo/PSUpdateApp/archive/master.zip) or play with the [example project](https://github.com/danielebogo/PSUpdateApp/tree/master/Projects). Open **PSUpdateApp.xcworkspace** (CocoaPods need).

## Integration

PSUpdateApp has a simple integration:

- Import **PSUpdateApp.h** into your AppDelegate or Pre-Compiler Header (.pch)
- In your AppDelegate.m `application:didFinishLaunchingWithOptions:` create your PSUpdateApp object.

``` objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[MainViewController alloc] init];
    [self.window makeKeyAndVisible];
    
//--- DEFAULT MODE
//    Start in default mode with your appID.
    [[PSUpdateApp manager] startWithAppID:@"454638411"];

//--- CUSTOM LOCATION MODE
//    Start with your appID and with the store location. The default mode set the store location by the device location.
//    More information about the store code here: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
//    [[PSUpdateApp manager] startWithAppID:@"454638411" store:@"US"];
  
//--- CUSTOM URL MODE
//    You can start with a custom url, if you want to detect the version about a ad hoc distribution app.
//    [[PSUpdateApp manager] startWithRoute:FAKE_ROUTE];
    
//--- ALERT STRATEGIES
//    The strategies change the Alert buttons rappresentation
//    The Default Strategy has 2 buttons: "Skip this version" ans "Update"
//    You can set your strategy with:
//    DefaultStrategy   -> default mode
//    ForceStrategy     -> force the update. The alert has only the update button
//    RemindStrategy    -> Add the remind me button.
//    
//    You can set the strategy with:
//    [[PSUpdateApp manager] setStrategy:RemindStrategy];
//    
//    With RemindStrategy the alert will appear after 2 days (2 is the default value) from the remind action.
//    If you want you can set the days until promt with:
//    [[PSUpdateApp manager] setDaysUntilPrompt:10];

//--- ALERT TEXT
//    You can set a custom title and/or a custom message for the PSUpdateApp alert
//    [[PSUpdateApp manager] setAlertTitle:@"Custom Title"];
//    [[PSUpdateApp manager] setAlertDefaultMessage:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit."];

//    3 different properties for the message:
//    alertDefaultMessage   -> default mode
//    alertForceMessage     -> force the update. The alert has only the update button
//    alertRemindMessage    -> Add the remind me button.

    return YES;
}
```
- In your AppDelegate.m `applicationDidBecomeActive:` start detect the available app version.

``` objective-c
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

//--- DETECT VERSION
//    Start to detect the version. In this case the block is nil, and the component use the default alert
    [[PSUpdateApp manager] detectAppVersion:nil];
    
//--- DETECT VERSION WITH BLOCK
//    You can use the completion block to implement you custom alert and actions
//    [[PSUpdateApp manager] detectAppVersion:^(NSError *error, BOOL success) {
//        NSLog(@"UPDATE");
//    }];
}
```
### Custom Url

If you want to use PSUpdateApp in a distribution ad hoc, or in an enterprise app, you can start PSUpdateApp with `startWithRoute:` using a JSON with this structure:

<pre>
{
  "results": [
    {
      "version": "3.0",
      "trackViewUrl": "http://paperstreetsoapdesign.com/development/updateapp/update.html",
      "type":"mandatory"
    }
  ]
}
</pre>

Use `setURLAdHoc:` if you want to create a `stringWithFormat:` between your custom url and the appStoreLocation property of PSUpdateApp.

### Notes

- This project requires ARC and iOS target from 6.0
- Use the PSUpdateApp properties to change the PSUpdateApp default value: for example the **app name** or **store location**
- It's localized
- It has a simple BDD test inside the example project
- Into the custom JSON structure, it's a new field called "type", to set the PSUpdateStrategy from remote (DefaultStrategy or ForceStrategy).

### Localizations
- English
- Italian
- Spanish
- Arabic
- Korean
- Chinese
- Russian

### Version

2.0.4

### Created by:

[Daniele Bogo](http://paperstreetsoapdesign.com)  

### Credits
- Arabic Localization by [Ehab Abdou](https://github.com/XemaCobra)
- Korean Localization by [Sean Moon](https://github.com/seanmoon)
- Chinese Localization by [Sean Wang](https://github.com/Sean-Wang)
- Russian Localization by [Almas Adilbek](https://github.com/mixdesign)

### License
The MIT License (MIT)
Copyright (c) 2014 Paper Street Soap Design

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
