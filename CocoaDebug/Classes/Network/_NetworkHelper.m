//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

#import "_NetworkHelper.h"
#import "_HttpModel.h"
#import "_HttpDatasource.h"
#import "_CustomHTTPProtocol.h"

@interface _NetworkHelper()

@end

@implementation _NetworkHelper

+ (instancetype)shared
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

//default value for @property
- (id)init {
    if (self = [super init])  {
        _isNetworkEnable = YES;
    }
    return self;
}

- (void)enable
{
    _isNetworkEnable = YES;
    [NSURLProtocol registerClass:[_CustomHTTPProtocol class]];
}

- (void)disable
{
    _isNetworkEnable = NO;
    [NSURLProtocol unregisterClass:[_CustomHTTPProtocol class]];
}
- (void)handleHttpWithModel:(_HttpModel *)model;
{
    if (!_isNetworkEnable) return;
    if ([_HttpDatasource.shared addHttpRequset:model])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadHttp_CocoaDebug" object:nil userInfo:@{@"statusCode": model.statusCode}];
    }

}
@end
