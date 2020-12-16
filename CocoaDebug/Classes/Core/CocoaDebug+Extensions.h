//
//  CocoaDebug+Extensions.h
//  CocoaDebug
//
//  Created by iPaperman on 2020/12/3.
//

#import <CocoaDebug/CocoaDebug.h>

#define _successStatusCodes       @[@"200",@"201",@"202",@"203",@"204",@"205",@"206",@"207",@"208",@"226"]
#define _informationalStatusCodes @[@"100",@"101",@"102",@"103",@"122"]
#define _redirectionStatusCodes   @[@"300",@"301",@"302",@"303",@"304",@"305",@"306",@"307",@"308"]

@interface NSString (Extensions)
@property (readonly) NSString *headerString;
@end

@interface NSDictionary (Extensions)
@property (readonly) NSData *dictionaryToData;
@property (readonly) NSString *dictionaryToString;
@property (readonly) NSString *headerToString;
@end

@interface NSData (Extensions)
@property (readonly) NSString *dataToString;
@property (readonly) NSDictionary *dataToDictionary;
@property (readonly) NSString *dataToPrettyPrintString;
@end

@interface UITableView (Extensions)
- (void)tableViewScrollToBottomAnimated:(BOOL)animated;
- (void)tableViewScrollToHeaderAnimated:(BOOL)animated;
@end

@interface UIColor (Extensions)
@property (copy, nonatomic, class, readonly) NSArray *colorGradientHead;

@property (copy, nonatomic, class, readonly) UIColor *mainGreen;
@end

@interface NSString (Extensions_Color)
@property (nonatomic, readonly) UIColor *hexColor;
@end

@interface UIWindow (Extensions)

@end

@interface CocoaDebug (Extensions)

+ (void)initializationServerURL:(NSString *)serverURL
                    ignoredURLs:(NSArray *)ignoredURLs
                       onlyURLs:(NSArray *)onlyURLs
       additionalViewController:(UIViewController *)additionalViewController
              emailToRecipients:(NSArray *)emailToRecipients
              emailCcRecipients:(NSArray *)emailCcRecipients
                      mainColor:(NSString *)mainColor
            protobufTransferMap:(NSDictionary<NSString *, NSArray<NSString*> *> *)protobufTransferMap;

+ (void)deinitialization;

@end
