//
//  PSAppDelegate.m
//  PSUpdateApp
//
//  Created by iBo on 18/02/13.
//  Copyright (c) 2013 D-Still. All rights reserved.
//

#import "PSAppDelegate.h"
#import "MainViewController.h"

#define FAKE_ROUTE @"http://paperstreetsoapdesign.com/development/updateapp/fake.json"

@implementation PSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[MainViewController alloc] init];
    [self.window makeKeyAndVisible];
    
//--- DEFAULT MODE
//    Start in default mode with your appID.
    [PSUpdateApp startWithAppID:@"529119648"];


//--- CUSTOM LOCATION MODE
//    Start with your appID and with the store location. The default mode set the store location by the device location.
//    More information about the store code here: http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
//    [PSUpdateApp startWithAppID:@"529119648" store:@"US"];
  
//--- CUSTOM URL MODE
//    You can start with a custom url, if you want to detect the version about a ad hoc distribution app.
//    [PSUpdateApp startWithRoute:FAKE_ROUTE];
    
//--- ALERT STRATEGIES
//    The strategies change the Alert buttons rappresentation
//    The Default Strategy has 2 buttons: "Skip this version" and "Update"
//    You can set your strategy with:
//    DefaultStrategy   -> default mode
//    ForceStrategy     -> force the update. The alert has only the update button
//    RemindStrategy    -> Add the remind me button.
//    
//    You can set the strategy with:
//    [[PSUpdateApp sharedPSUpdateApp] setStrategy:RemindStrategy];
//    
//    With RemindStrategy the alert will appear after 2 days (2 is the default value) from the remind action.
//    If you want you can set the days until promt with:
//    [[PSUpdateApp sharedPSUpdateApp] setDaysUntilPrompt:10];
    
    
    
//    For more information read the documentation here: https://github.com/danielebogo/PSUpdateApp

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

//--- DETECT VERSION
//    Start to detect the version. In this case the block is nil, and the component use the default alert
    [[PSUpdateApp sharedPSUpdateApp] detectAppVersion:nil];
    
//--- DETECT VERSION WITH BLOCK
//    You can use the completion block to implement you custom alert and actions
//    [[PSUpdateApp sharedPSUpdateApp] detectAppVersion:^(NSError *error, BOOL success, id JSON) {
//        NSLog(@"UPDATE: %@", JSON);
//    }];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
