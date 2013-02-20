PSUpdateApp
===========

## A simple method to notify users that a new version of your iOS app is available.

### About
**PSUpdateApp** notify you if exist a new version of your iOS application available in the AppStore or in other place.<br />
If a new version is available, PSUpdateApp presents an UIAlertView, that informs you of the newer version, and gives the option to update the application.<br />
The component is based on **[AFNetworking](https://github.com/AFNetworking/AFNetworking/ "AFNetworking")** framework, using [`AFJSONRequestOperation`](http://afnetworking.github.com/AFNetworking/Classes/AFJSONRequestOperation.html) method to read and parse the json response.<br />
The object is a singleton based on Matt Gallager object ([More informations here](http://www.cocoawithlove.com/2008/11/singletons-appdelegates-and-top-level.html)).

##Getting Started

### Installation

The recommended approach for installating PSUpdateApp is via the [CocoaPods](http://cocoapods.org/) package manager, as it provides flexible dependency management and dead simple installation. For best results, it is recommended that you install via CocoaPods **>= 0.16.0** using Git **>= 1.8.0** installed via Homebrew.

#### via CocoaPods

Install CocoaPods if not already available:

``` bash
$ [sudo] gem install cocoapods
$ pod setup
```

Change to the directory of your Xcode project, and Create and Edit your Podfile and add RestKit:

``` bash
$ cd /path/to/MyProject
$ touch Podfile
$ edit Podfile
platform :ios, '5.0' 
# Or platform :osx, '10.7'
pod 'PSUpdateApp', '~> 1.0'
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

[Download PSUpdateApp](https://github.com/danielebogo/PSUpdateApp/archive/master.zip) or play with the [example project](https://github.com/danielebogo/PSUpdateApp/tree/master/Project). Open **PSUpdateApp.xcworkspace** (CocoaPods need).