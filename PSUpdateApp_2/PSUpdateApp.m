//
//  PSUpdateApp.m
//  PSUpdateApp
//
//  Created by iBo on 18/02/13.
//  Copyright (c) 2013 D-Still. All rights reserved.
//

#ifndef PSUdateAppLocalizedStrings
#define PSUdateAppLocalizedStrings(key) \
NSLocalizedStringFromTable(key, @"PSUdateApp", nil)
#endif

#import "PSUpdateApp.h"

#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <AFNetworking/AFURLResponseSerialization.h>

#define APPLE_URL @"http://itunes.apple.com/lookup?"

#define kCurrentAppVersion [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]

#ifdef DEBUG
#define DebugLog(...) NSLog(__VA_ARGS__)
#else
#define DebugLog(...) { }
#endif

@interface NSObject (StringValidation)
- (BOOL) isValidObject;
- (BOOL) isValidString;
@end

@implementation NSObject (ObjectValidation)

- (BOOL) isValidObject
{
    if ( self && ![self isEqual:[NSNull null]] && [self isKindOfClass:[NSObject class]] )
        return YES;
    else
        return NO;
}

- (BOOL) isValidString
{
    if ( [self isValidObject] && [self isKindOfClass:[NSString class]] && ![(NSString *)self isEqualToString:@""] )
        return YES;
    else
        return NO;
}

@end

//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

@interface PSUpdateApp () <UIAlertViewDelegate> {
    NSString *_newVersion;
}
@end

@implementation PSUpdateApp

+ (PSUpdateApp *) manager
{
    static PSUpdateApp *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[PSUpdateApp alloc] init];
    });
    return sharedInstance;
}

- (void) startWithRoute:(NSString *)route
{
    [self initWithAppID:nil store:nil route:route];
}

- (void) startWithAppID:(NSString *)appId store:(NSString *)store
{
    [self initWithAppID:appId store:store route:nil];
}

- (void) startWithAppID:(NSString *)appId
{
    [self initWithAppID:appId store:nil route:nil];
}

- (void) initWithAppID:(NSString *)appId store:(NSString *)store route:(NSString *)route
{
    [self setAppName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
    [self setStrategy:DefaultStrategy];
    [self setAppID:appId];
    [self setAppStoreLocation: store ? store : [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode]];
    [self setDaysUntilPrompt:2];
    [self setRoute:route];
}

- (void) detectAppVersion:(PSUpdateAppCompletionBlock)completionBlock
{   
    if ( _strategy == RemindStrategy && [self remindDate] != nil && ![self checkConsecutiveDays] )
        return;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager GET:[self setJsonURL] parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             DebugLog(@"JSON response: %@", responseObject);
             
             if ( [self isNewVersion:responseObject] ) {
                 if ( completionBlock && ![self isSkipVersion] )
                     completionBlock(nil, YES, responseObject);
                 else if ( ![self isSkipVersion] )
                     [self showAlert];
                 else {
                     if ( completionBlock )
                         completionBlock(nil, NO, responseObject);
                 }
             } else {
                 if ( completionBlock )
                     completionBlock(nil, NO, responseObject);
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if ( completionBlock && ![self isSkipVersion] )
                 completionBlock(error, NO, nil);
         }];
}

- (NSString *) setJsonURL
{
    return self.route ? self.route : [NSString stringWithFormat:@"%@id=%@&country=%@", APPLE_URL, self.appID, self.appStoreLocation];
}

- (void) setURLAdHoc:(NSString *)url
{
    [self setRoute:[NSString stringWithFormat:url, self.appStoreLocation]];
}

#pragma mark - Check version

- (BOOL) isNewVersion:(NSDictionary *)dictionary
{
    if ( [dictionary[@"results"] count] > 0 ) {
        _newVersion = dictionary[@"results"][0][@"version"];
        [self setUpdatePageUrl:dictionary[@"results"][0][@"trackViewUrl"]];
        
        if ( dictionary[@"results"][0][@"type"] ) {
            [self setStrategy: [dictionary[@"results"][0][@"type"] isEqualToString:@"mandatory"] ? ForceStrategy : DefaultStrategy];
        }
        
        return [kCurrentAppVersion compare:_newVersion options:NSNumericSearch] == NSOrderedAscending;
    }
    
    return NO;
}

- (BOOL) isSkipVersion
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"skipVersion"] isEqualToString:_newVersion];
}

#pragma mark - remindDate getter / setter

- (NSDate *) remindDate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"remindDate"];
}

- (void) setRemindDate:(NSDate *)remindDate
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"remindDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Show alert

- (void) showAlert
{
    NSString *alertTitle = [self.alertTitle isValidString] ? self.alertTitle : PSUdateAppLocalizedStrings(@"alert.success.title");
    
    switch ( self.strategy ) {
        case DefaultStrategy:
        default:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                message:[self.alertDefaultMessage isValidString] ? self.alertDefaultMessage : [NSString stringWithFormat:PSUdateAppLocalizedStrings(@"alert.success.default.text"), self.appName, _newVersion]
                                                               delegate:self
                                                      cancelButtonTitle:PSUdateAppLocalizedStrings(@"alert.button.skip")
                                                      otherButtonTitles:PSUdateAppLocalizedStrings(@"alert.button.update"), nil];
            [alertView show];
        }
            break;
            
        case ForceStrategy:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                message:[self.alertForceMessage isValidString] ? self.alertForceMessage : [NSString stringWithFormat:PSUdateAppLocalizedStrings(@"alert.success.force.text"), self.appName, _newVersion]
                                                               delegate:self
                                                      cancelButtonTitle:PSUdateAppLocalizedStrings(@"alert.button.update")
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;
            
        case RemindStrategy:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                message:[self.alertRemindMessage isValidString] ? self.alertRemindMessage : [NSString stringWithFormat:PSUdateAppLocalizedStrings(@"alert.success.remindme.text"), _appName, _newVersion]
                                                               delegate:self
                                                      cancelButtonTitle:PSUdateAppLocalizedStrings(@"alert.button.skip")
                                                      otherButtonTitles:PSUdateAppLocalizedStrings(@"alert.button.update"), PSUdateAppLocalizedStrings(@"alert.button.remindme"), nil];
            [alertView show];
        }
            break;
    }
}


#pragma mark - UIAlertViewDelegate Methods

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{   
    switch ( self.strategy ) {
        case DefaultStrategy:
        default:
        {
            if ( buttonIndex == 0 ) {
                [[NSUserDefaults standardUserDefaults] setObject:_newVersion forKey:@"skipVersion"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updatePageUrl]];
            }
        }

            break;
            
        case ForceStrategy:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updatePageUrl]];
            break;
            
        case RemindStrategy:
        {
            if ( buttonIndex == 0 ) {
                [[NSUserDefaults standardUserDefaults] setObject:_newVersion forKey:@"skipVersion"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else if ( buttonIndex == 1 )
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updatePageUrl]];
            else
                [self setRemindDate:[NSDate date]];
        }

            break;
    }
}

#pragma mark - Check if have passed

- (BOOL) checkConsecutiveDays
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *today = [NSDate date];
    
    NSDate *dateToRound = [[self remindDate] earlierDate:today];
    NSDateComponents * dateComponents = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                     fromDate:dateToRound];
    
    NSDate *roundedDate = [gregorian dateFromComponents:dateComponents];
    NSDate *otherDate = (dateToRound == [self remindDate]) ? today : [self remindDate] ;
    NSInteger diff = abs([roundedDate timeIntervalSinceDate:otherDate]);
    NSInteger daysDifference = floor(diff/(24 * 60 * 60));
    
    return daysDifference >= _daysUntilPrompt;
}

@end
