//
//  PSUpdateApp.h
//  PSUpdateApp
//
//  Created by iBo on 18/02/13.
//  Copyright (c) 2013 D-Still. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PSUpdateAppCompletionBlock)(NSError *error, BOOL success, id JSON);

typedef enum {
    DefaultStrategy = 0,
    ForceStrategy,
    RemindStrategy
} UpdateStrategy;

@interface PSUpdateApp : NSObject

@property (nonatomic, strong) NSString *appID, *appStoreLocation, *appName, *route, *updatePageUrl;
@property (nonatomic, strong) NSString *alertTitle, *alertDefaultMessage, *alertForceMessage, *alertRemindMessage;
@property (nonatomic, assign) UpdateStrategy strategy;
@property (nonatomic, assign) NSUInteger daysUntilPrompt;
@property (nonatomic, strong) NSDate *remindDate;

+ (PSUpdateApp *) manager;

- (void) startWithRoute:(NSString *)route;
- (void) startWithAppID:(NSString *)appId;
- (void) startWithAppID:(NSString *)appId store:(NSString *)store;

- (void) detectAppVersion:(PSUpdateAppCompletionBlock)completionBlock;
- (void) setURLAdHoc:(NSString *)url;

@end