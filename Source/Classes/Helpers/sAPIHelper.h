//
//  sAPIHelper.h
//  sAPI
//
//  Created by jinsikui on 2021/9/6.
//

#import <Foundation/Foundation.h>

#define sapi_not_null(x) (x != nil && ![x isKindOfClass:[NSNull class]])

NS_ASSUME_NONNULL_BEGIN

@interface sAPIHelper : NSObject

+ (NSString*)urlEncode:(NSString*)input;

+ (NSString*)mergeToInput:(NSString*)input queryParams:(NSDictionary*)params;

@end

NS_ASSUME_NONNULL_END
