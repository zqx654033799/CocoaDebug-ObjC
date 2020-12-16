//
//  CocoaDebug.m
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/3.
//

#import "CocoaDebug+Extensions.h"

///if the captured URLs contain server URL, CocoaDebug set server URL bold font to be marked. Not mark when this value is nil. Default value is `nil`.
static NSString * _serverURL = nil;
///set the URLs which should not been captured, CocoaDebug capture all URLs when the value is nil. Default value is `nil`.
static NSArray * _ignoredURLs = nil;
///set the URLs which are only been captured, CocoaDebug capture all URLs when the value is nil. Default value is `nil`.
static NSArray * _onlyURLs = nil;
///add an additional UIViewController as child controller of CocoaDebug's main UITabBarController. Default value is `nil`.
static UIViewController * _additionalViewController = nil;
///set the initial recipients to include in the email’s “To” field when share via email. Default value is `nil`.
static NSArray * _emailToRecipients = nil;
///set the initial recipients to include in the email’s “Cc” field when share via email. Default value is `nil`.
static NSArray * _emailCcRecipients = nil;
///set CocoaDebug's main color with hexadecimal format. Default value is `#42d459`.
static NSString * _mainColor = @"#42d459";
///protobuf url and response class transfer map. Default value is `nil`.
static NSDictionary<NSString *,NSArray<NSString *> *> * _protobufTransferMap = nil;

@implementation CocoaDebug

+ (NSInteger)logMaxCount {
    return 1000;
}

+ (NSString *)mainColor {
    return _mainColor;
}

#pragma mark - CocoaDebug enable
+ (void)enable;
{
    [self initializationServerURL:_serverURL
                      ignoredURLs:_ignoredURLs
                         onlyURLs:_onlyURLs
         additionalViewController:_additionalViewController
                emailToRecipients:_emailToRecipients
                emailCcRecipients:_emailCcRecipients
                        mainColor:_mainColor
              protobufTransferMap:_protobufTransferMap];
}

#pragma mark - CocoaDebug disable
+ (void)disable;
{
    [self deinitialization];
}

@end
