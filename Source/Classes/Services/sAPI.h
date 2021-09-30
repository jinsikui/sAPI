//
//  sAPI.h
//  LiveLib_Example
//
//  Created by DemonY on 2020/7/30.
//  Copyright © 2020 蜻蜓fm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sAPIDepends.h"

#define sAPIErrorDomain @"sAPIErrorDomain"
#define sAPIErrorMessageKey @"sAPIErrorMessageKey"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, sAPICommonParamsUsage) {
    sAPICommonParamsUsageNone = 0,
    sAPICommonParamsUsagePath = 1 << 1,
    sAPICommonParamsUsageParams = 1 << 2,
};

typedef NS_ENUM(NSUInteger, sAPICommonHeadersUsage) {
    sAPICommonHeadersUsageNone = 0,
    sAPICommonHeadersUsageHeaders = 1 << 1,
};

typedef FBLPromise * _Nullable (^SAPIBeforeNetworkCallbackBlock)(void);
typedef NSDictionary * _Nonnull (^SAPISetParamsBlock)(NSString *_Nullable);
typedef NSDictionary * _Nonnull (^SAPISetHeadersBlock)(NSString *_Nullable);

@interface sAPIBaseBuilder : NSObject

@property (nonatomic, copy, nullable, readonly) SAPISetParamsBlock paramsBlock;
@property (nonatomic, copy, nullable, readonly) SAPISetHeadersBlock headersBlock;
@property(nonatomic, strong, readonly) void (^commonParams)(SAPISetParamsBlock commonParamsBlock);
@property(nonatomic, strong, readonly) void (^commonHeaders)(SAPISetHeadersBlock commonHeadersBlock);
@property (nonatomic, copy, readonly) void (^defaultHost)(NSString *defaultHost);
@property (nonatomic, assign, readonly) void (^defaultMethod)(sHTTPMethod defaultMethod);

+ (instancetype)shared;
- (instancetype)init NS_UNAVAILABLE;

@end

@interface sAPIConvertable : NSObject <sRequestConvertable>

- (instancetype)initWithParams:(NSDictionary * _Nullable)params
                       headers:(NSDictionary * _Nullable)headers
                          host:(NSString * _Nullable)host
                          path:(NSString * _Nullable)path
                        method:(sHTTPMethod)method
                  encodingType:(sParameterEncoding)encodingType
                  decodingType:(sResponseDecncoding)decodingType
                      stubData:(sNetworkSub* _Nullable)stubData;
@end

@interface sAPIBuilder : NSObject
/// 设置一个标志，传给构造commonParams和commonHeaders的block
@property (nonatomic, copy, readonly) sAPIBuilder * (^tag)(NSString *tag);
@property (nonatomic, copy, readonly) sAPIBuilder * (^stubData)(sNetworkSub *stubData);
@property (nonatomic, copy, readonly) sAPIBuilder * (^params)(NSDictionary *params);
@property (nonatomic, copy, readonly) sAPIBuilder * (^headers)(NSDictionary *headers);
@property(nonatomic, assign, readonly) sAPIBuilder * (^commonParamsUsage)(sAPICommonParamsUsage commonParamsUsage);
@property(nonatomic, assign, readonly) sAPIBuilder * (^commonHeadersUsage)(sAPICommonHeadersUsage commonHeadersUsage);
@property(nonatomic, copy, readonly) sAPIBuilder * (^host)(NSString *host);
@property(nonatomic, copy, readonly) sAPIBuilder * (^path)(NSString *path);
@property(nonatomic, assign, readonly) sAPIBuilder * (^method)(sHTTPMethod method);
@property(nonatomic, assign, readonly) sAPIBuilder * (^encodingType)(sParameterEncoding encodingType);
@property(nonatomic, assign, readonly) sAPIBuilder * (^decodingType)(sResponseDecncoding decodingType);
@property(nonatomic, copy, readonly) sAPIBuilder * (^beforeNetworkCallback)(SAPIBeforeNetworkCallbackBlock beforeCallback);
@property(nonatomic, copy, readonly) FBLPromise * (^execute)(void);

@end

@interface sAPI : NSObject

#pragma mark - Common API Properties

+ (void)buildCommon:(void(^)(sAPIBaseBuilder *baseBuilder))block;
@property(nonatomic, strong, class, readonly) void (^commonParams)(SAPISetParamsBlock commonParamsBlock);
@property(nonatomic, strong, class, readonly) void (^commonHeaders)(SAPISetHeadersBlock commonHeadersBlock);
@property (nonatomic, copy, class, readonly) void (^defaultHost)(NSString *defaultHost);
@property (nonatomic, assign, class, readonly) void (^defaultMethod)(sHTTPMethod defaultMethod);

#pragma mark - Instance API Properties

+ (sAPIBuilder *)build:(void(^_Nullable)(sAPIBuilder *builder))block;
@property(nonatomic, strong, class, readonly) sAPIBuilder * (^tag)(NSString *tag);
@property(nonatomic, strong, class, readonly) sAPIBuilder * (^stubData)(sNetworkSub *stubData);
@property(nonatomic, strong, class, readonly) sAPIBuilder * (^params)(NSDictionary *params);
@property(nonatomic, strong, class, readonly) sAPIBuilder * (^headers)(NSDictionary *headers);
@property(nonatomic, assign, class, readonly) sAPIBuilder * (^commonParamsUsage)(sAPICommonParamsUsage commonParamsUsage);
@property(nonatomic, assign, class, readonly) sAPIBuilder * (^commonHeadersUsage)(sAPICommonHeadersUsage commonHeadersUsage);
@property(nonatomic, copy, class, readonly) sAPIBuilder * (^host)(NSString *host);
@property(nonatomic, copy, class, readonly) sAPIBuilder * (^path)(NSString *path);
@property(nonatomic, assign, class, readonly) sAPIBuilder * (^method)(sHTTPMethod method);
@property(nonatomic, assign, class, readonly) sAPIBuilder * (^encodingType)(sParameterEncoding encodingType);
@property(nonatomic, copy, class, readonly) sAPIBuilder * (^beforeNetworkCallback)(SAPIBeforeNetworkCallbackBlock beforeCallback);

@end

NS_ASSUME_NONNULL_END
