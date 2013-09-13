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
#import <AFNetworking/AFNetworking.h>

#define APPLE_URL @"http://itunes.apple.com/lookup?"

#define kCurrentAppVersion [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]

@interface PSUpdateApp () <UIAlertViewDelegate> {
    NSString *_newVersion;
}
@end

@implementation PSUpdateApp

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(PSUpdateApp)

+ (id) startWithRoute:(NSString *)route
{
    return [[self alloc] initWithAppID:nil store:nil route:route];
}

+ (id) startWithAppID:(NSString *)appId store:(NSString *)store
{
    return [[self alloc] initWithAppID:appId store:store route:nil];
}

+ (id) startWithAppID:(NSString *)appId
{
    return [[self alloc] initWithAppID:appId store:nil route:nil];
}

- (id) initWithAppID:(NSString *)appId store:(NSString *)store route:(NSString *)route
{
    self = [super init];
    
    if ( self ) {
        [self setAppName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
        [self setStrategy:DefaultStrategy];
        [self setAppID:appId];
        [self setAppStoreLocation: store ? store : [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode]];
        [self setDaysUntilPrompt:2];
        [self setRoute:route];
    }
    
    return self;
}

- (void) detectAppVersion:(PSUpdateAppCompletionBlock)completionBlock
{   
    if ( _strategy == RemindStrategy && [self remindDate] != nil && ![self checkConsecutiveDays] )
        return;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[self setJsonURL]]];
    [request setHTTPMethod:@"GET"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            if ( [self isNewVersion:JSON] ) {
                                                                                                if ( completionBlock && ![self isSkipVersion] ) {
                                                                                                    completionBlock(nil, YES, JSON);
                                                                                                } else if ( ![self isSkipVersion] ) {
                                                                                                    [self showAlert];
                                                                                                } else {
                                                                                                    if ( completionBlock )
                                                                                                        completionBlock(nil, NO, JSON);
                                                                                                }
                                                                                            } else {
                                                                                                if ( completionBlock )
                                                                                                    completionBlock(nil, NO, JSON);
                                                                                            }
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            if ( completionBlock && ![self isSkipVersion] )
                                                                                                completionBlock(error, NO, nil);
                                                                                        }];
    [operation start];
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
    if ( [[dictionary objectForKey:@"results"] count] > 0 ) {
        _newVersion = [[[dictionary objectForKey:@"results"] objectAtIndex:0] objectForKey:@"version"];
        [self setUpdatePageUrl:[[[dictionary objectForKey:@"results"] objectAtIndex:0] objectForKey:@"trackViewUrl"]];
        
        if ([[[dictionary objectForKey:@"results"] objectAtIndex:0] objectForKey:@"type"]) {
            [self setStrategy: [[[[dictionary objectForKey:@"results"] objectAtIndex:0] objectForKey:@"type"] isEqualToString:@"mandatory"] ? ForceStrategy : DefaultStrategy];
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
    switch ( self.strategy ) {
        case DefaultStrategy:
        default:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:PSUdateAppLocalizedStrings(@"alert.success.title")
                                                                message:[NSString stringWithFormat:PSUdateAppLocalizedStrings(@"alert.success.default.text"), self.appName, _newVersion]
                                                               delegate:self
                                                      cancelButtonTitle:PSUdateAppLocalizedStrings(@"alert.button.skip")
                                                      otherButtonTitles:PSUdateAppLocalizedStrings(@"alert.button.update"), nil];
            [alertView show];
        }
            break;
            
        case ForceStrategy:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:PSUdateAppLocalizedStrings(@"alert.success.title")
                                                                message:[NSString stringWithFormat:PSUdateAppLocalizedStrings(@"alert.success.force.text"), self.appName, _newVersion]
                                                               delegate:self
                                                      cancelButtonTitle:PSUdateAppLocalizedStrings(@"alert.button.update")
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;
            
        case RemindStrategy:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:PSUdateAppLocalizedStrings(@"alert.success.title")
                                                                message:[NSString stringWithFormat:PSUdateAppLocalizedStrings(@"alert.success.remindme.text"), _appName, _newVersion]
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
            } else if ( buttonIndex == 1 ) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updatePageUrl]];
            } else {
                [self setRemindDate:[NSDate date]];
            }
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
