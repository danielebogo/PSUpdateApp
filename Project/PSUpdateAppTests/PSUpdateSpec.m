#import "Kiwi.h"
#import "PSUpdateApp.h"

SPEC_BEGIN(PSUpdateSpec)

describe(@"PSUpdateApp start:", ^{
    it(@"create PSUpdate object", ^{
        [theValue([PSUpdateApp startWithAppID:@"529119648"]) shouldNotBeNil];
    });
    
    it(@"detect the version without block", ^{
        [[PSUpdateApp sharedPSUpdateApp] detectAppVersion:nil];
    });
    
    context(@"PSUpdateApp Asynchronous Testing", ^{
        __block BOOL fetchedData;
        
        it(@"new version exist with block", ^{
            
            [[PSUpdateApp sharedPSUpdateApp] detectAppVersion:^(NSError *error, BOOL success) {
                fetchedData = success;
            }];
            
            [[expectFutureValue(theValue(fetchedData)) shouldEventually] beYes];
        });
        
        it(@"new version doesn't exist with block", ^{
            
            [[PSUpdateApp sharedPSUpdateApp] detectAppVersion:^(NSError *error, BOOL success) {
                fetchedData = success;
            }];
            
            [[expectFutureValue(theValue(fetchedData)) shouldEventually] beNo];
        });
        
    });
});

SPEC_END