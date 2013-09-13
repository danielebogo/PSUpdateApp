//
//  PSUpdateApp.h
//  PSUpdateApp
//
//  Created by iBo on 18/02/13.
//  Copyright (c) 2013 D-Still. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"

typedef void(^PSUpdateAppCompletionBlock)(NSError *error, BOOL success, id JSON);

typedef enum {
    DefaultStrategy = 0,
    ForceStrategy,
    RemindStrategy
} UpdateStrategy;

@interface PSUpdateApp : NSObject

CWL_DECLARE_SINGLETON_FOR_CLASS(PSUpdateApp)

@property (nonatomic) NSString *appID, *appStoreLocation, *appName, *route, *updatePageUrl;
@property (nonatomic) UpdateStrategy strategy;
@property (nonatomic) int daysUntilPrompt;
@property (nonatomic) NSDate *remindDate;

+ (id) startWithRoute:(NSString *)route;
+ (id) startWithAppID:(NSString *)appId;
+ (id) startWithAppID:(NSString *)appId store:(NSString *)store;

- (void) detectAppVersion:(PSUpdateAppCompletionBlock)completionBlock;
- (void) setURLAdHoc:(NSString *)url;

@end