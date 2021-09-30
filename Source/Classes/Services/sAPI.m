//
//  sAPI.m
//  LiveLib_Example
//
//  Created by DemonY on 2020/7/30.
//  Copyright © 2020 蜻蜓fm. All rights reserved.
//

#import "sAPI.h"

@interface sAPIBaseBuilder ()
@property (nonatomic, copy, nullable, readwrite) SAPISetParamsBlock paramsBlock;
@property (nonatomic, copy, nullable, readwrite) SAPISetHeadersBlock headersBlock;
@property (nonatomic, copy) NSString *mDefaultHost;
@property (nonatomic, assign) sHTTPMethod mDefaultMethod;
@end

@implementation sAPIBaseBuilder

+ (instancetype)shared {
    static sAPIBaseBuilder *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[sAPIBaseBuilder alloc] init];
    });
    return instance;
}

- (void (^)(SAPISetParamsBlock _Nonnull))commonParams {
    return ^(SAPISetParamsBlock commonParamsBlock) {
        self.paramsBlock = commonParamsBlock;
    };
}

- (void (^)(SAPISetHeadersBlock _Nonnull))commonHeaders {
    return ^(SAPISetHeadersBlock commonHeadersBlock) {
        self.headersBlock = commonHeadersBlock;
    };
}

- (void (^)(NSString *defaultHost))defaultHost {
    return ^(NSString *defaultHost) {
        self.mDefaultHost = [defaultHost copy];
    };
}

- (void (^)(sHTTPMethod defaultMethod))defaultMethod {
    return ^(sHTTPMethod defaultMethod) {
        self.mDefaultMethod = defaultMethod;
    };
}

@end

@interface sAPIConvertable () {
    NSDictionary *_mParams;
    NSDictionary *_mHeaders;
    NSString *_mHost;
    NSString *_mPath;
    sHTTPMethod _mMethod;
    sParameterEncoding _mEncodingType;
    sResponseDecncoding _mDecodingType;
    sNetworkSub *_mStubData;
}
@end
@implementation sAPIConvertable

- (instancetype)initWithParams:(NSDictionary *)params
                       headers:(NSDictionary *)headers
                          host:(NSString *)host
                          path:(NSString *)path
                        method:(sHTTPMethod)method
                  encodingType:(sParameterEncoding)encodingType
                  decodingType:(sResponseDecncoding)decodingType
                      stubData:(sNetworkSub*)stubData{
    self = [super init];
    if (self) {
        _mParams = params;
        _mHeaders = headers;
        _mHost = host;
        _mPath = path;
        _mMethod = method;
        _mEncodingType = encodingType;
        _mDecodingType = decodingType;
        _mStubData = stubData;
    }
    return self;
}

#pragma mark - sNetworkConvertable
- (NSString*)baseURL {
    return _mHost;
}

- (NSDictionary<NSString *,NSString *> *)httpHeaders {
    return _mHeaders;
}

- (NSString *)path {
    return _mPath;
}

- (sHTTPMethod)httpMethod {
    return _mMethod;
}

- (NSDictionary *)parameters {
    return _mParams;
}

- (sParameterEncoding)encodingType {
    return _mEncodingType;
}

- (sResponseDecncoding)decodingType {
    return _mDecodingType;
}

- (sNetworkSub*)stubData{
    return _mStubData;
}

- (sNetworkResponse *)adaptResponse:(sNetworkResponse *)networkResponse {
    return [[sNetworkResponse alloc] initWithResponse:networkResponse adpatedObject:networkResponse.responseObject];
}

@end

@interface sAPIBuilder ()

@property (nonatomic, copy, readwrite) NSString *mTag;
@property (nonatomic, strong, readwrite) sNetworkSub *mStubData;
@property (nonatomic, strong, readwrite) NSDictionary *mParams;
@property (nonatomic, strong, readwrite) NSDictionary *mHeaders;
@property (nonatomic, assign, readwrite) sAPICommonParamsUsage mParamUsage;
@property (nonatomic, assign, readwrite) sAPICommonHeadersUsage mHeaderUsage;
@property (nonatomic, copy, readwrite) NSString *mHost;
@property (nonatomic, copy, readwrite) NSString *mPath;
@property (nonatomic, assign, readwrite) sHTTPMethod mMethod;
@property (nonatomic, assign, readwrite) sParameterEncoding mEncodingType;
@property (nonatomic, assign, readwrite) sResponseDecncoding mDecodingType;
@property (nonatomic, copy, nullable, readwrite) SAPIBeforeNetworkCallbackBlock beforeCallback;

@property (strong, nonatomic) sNetworkManager * manager;
@end

@implementation sAPIBuilder

- (instancetype)init {
    self = [super init];
    if (self) {
        self.manager = [sNetworkManager manager];
        self.mEncodingType = sParameterEncodingJSON;
        self.mDecodingType = sResponseDecncodingJSON;
        self.mParamUsage = sAPICommonParamsUsagePath;
        self.mHeaderUsage = sAPICommonHeadersUsageHeaders;
        self.mMethod = [sAPIBaseBuilder shared].mDefaultMethod;
        self.mHost = [sAPIBaseBuilder shared].mDefaultHost;
    }
    return self;
}

- (sAPIBuilder * _Nonnull (^)(NSString * _Nonnull))tag {
    return ^id(NSString *tag) {
        self.mTag = tag;
        return self;
    };
}

- (sAPIBuilder * _Nonnull (^)(sNetworkSub * _Nonnull))stubData {
    return ^id(sNetworkSub *stubData) {
        self.mStubData = stubData;
        return self;
    };
}

- (sAPIBuilder * _Nonnull (^)(NSDictionary * _Nonnull))params {
    return ^id(NSDictionary *params) {
        self.mParams = params;
        return self;
    };
}

- (sAPIBuilder * _Nonnull (^)(NSDictionary * _Nonnull))headers {
    return ^id(NSDictionary *headers) {
        self.mHeaders = headers;
        return self;
    };
}

- (sAPIBuilder * _Nonnull (^)(sAPICommonParamsUsage))commonParamsUsage {
    return ^id(sAPICommonParamsUsage usage) {
        self.mParamUsage = usage;
        return self;
    };
}

- (sAPIBuilder * _Nonnull (^)(sAPICommonHeadersUsage))commonHeadersUsage {
    return ^id(sAPICommonHeadersUsage usage) {
        self.mHeaderUsage = usage;
        return self;
    };
}

- (sAPIBuilder * _Nonnull (^)(NSString * _Nonnull))host {
    return ^id(NSString *host) {
        self.mHost = [host copy];
        return self;
    };
}

- (sAPIBuilder * _Nonnull (^)(NSString * _Nonnull))path {
    return ^id(NSString *path) {
        self.mPath = [path copy];
        return self;
    };
}

- (sAPIBuilder * _Nonnull (^)(sHTTPMethod))method {
    return ^id(sHTTPMethod method) {
        self.mMethod = method;
        return self;
    };
}

- (sAPIBuilder * _Nonnull (^)(sParameterEncoding))encodingType {
    return ^id(sParameterEncoding encodingType) {
        self.mEncodingType = encodingType;
        return self;
    };
}

- (sAPIBuilder * _Nonnull (^)(sResponseDecncoding))decodingType {
    return ^id(sResponseDecncoding decodingType) {
        self.mDecodingType = decodingType;
        return self;
    };
}

- (sAPIBuilder * _Nonnull (^)(SAPIBeforeNetworkCallbackBlock _Nonnull))beforeNetworkCallback {
    return ^id(SAPIBeforeNetworkCallbackBlock beforeCallback) {
        self.beforeCallback = beforeCallback;
        return self;
    };
}

- (FBLPromise * (^)(void))execute {
    return ^FBLPromise * {
        FBLPromise * (^networkPromise)(void) = ^{
            return FBLPromise.asyncOn(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(FBLPromiseFulfillBlock fulfill, FBLPromiseRejectBlock reject) {
                void (^myCompletion)(sNetworkResponse * _Nonnull, NSInteger, NSString*) = ^(sNetworkResponse * _Nonnull response, NSInteger errorCode, NSString *errorMsg) {
                    if (errorCode != 0) {
                        NSError *error = [NSError errorWithDomain:sAPIErrorDomain code:errorCode userInfo:@{sAPIErrorMessageKey: errorMsg ?: @""}];
                        reject(error);
                    } else {
                        fulfill(response.responseObject);
                    }
                };
                [self.manager request:[self createConvertable] completion:[self getRequestCompletionFromCompletion:myCompletion]];
            });
        };
        /// 是否有在网络请求之前的回调
        if (self.beforeCallback) {
            FBLPromise *beforePromise = self.beforeCallback();
            if (beforePromise) {
                return beforePromise.then(^id _Nullable(id  _Nullable value) {
                    return networkPromise();
                });
            }
        }
        return networkPromise();
    };
}

- (sAPIConvertable *)createConvertable {
    NSMutableDictionary *commonParams = [NSMutableDictionary dictionary];
    if ([sAPIBaseBuilder shared].paramsBlock) {
        commonParams = [[sAPIBaseBuilder shared].paramsBlock(self.mTag) mutableCopy];
    }
    NSMutableDictionary *commonHeaders = [NSMutableDictionary dictionary];
    if ([sAPIBaseBuilder shared].headersBlock) {
        commonHeaders = [[sAPIBaseBuilder shared].headersBlock(self.mTag) mutableCopy];
    }
    /// 参数
    if (self.mParamUsage & sAPICommonParamsUsageParams) {
        [commonParams addEntriesFromDictionary:self.mParams];
        self.mParams = commonParams;
    }
    /// 头
    if (self.mHeaderUsage & sAPICommonHeadersUsageHeaders) {
        [commonHeaders addEntriesFromDictionary:self.mHeaders];
        self.mHeaders = commonHeaders;
    }
    /// 地址
    if (self.mParamUsage & sAPICommonParamsUsagePath) {
        self.mPath = [sAPIHelper mergeToInput:self.mPath queryParams:commonParams];
    }
    
    /// 编码
    sParameterEncoding encodingType = self.mMethod == HTTP_GET ? sParameterEncodingHTTP : self.mEncodingType;
    
    return [[sAPIConvertable alloc] initWithParams:self.mParams
                                           headers:self.mHeaders
                                              host:self.mHost
                                              path:self.mPath
                                            method:self.mMethod
                                      encodingType:encodingType
                                      decodingType:self.mDecodingType
                                          stubData:self.mStubData];
}

- (void(^)(sNetworkResponse * _Nonnull))getRequestCompletionFromCompletion:(void (^)(sNetworkResponse * _Nonnull, NSInteger errorCode, NSString *errorMsg))completion {
    void (^requestCompletion)(sNetworkResponse * _Nonnull) = ^(sNetworkResponse *response) {
        NSInteger errorCode = 0;
        NSString *errorMsg = nil;
        if (response.statusCode != 200) {
            errorCode = response.statusCode > 0 ? response.statusCode : 110; /*110代表请求超时*/
        }
        if ([response.responseObject isKindOfClass:NSDictionary.class]) {
            NSDictionary *body = response.responseObject;
            if (sapi_not_null(body[@"errcode"]) || sapi_not_null(body[@"code"]) || sapi_not_null(body[@"errorno"]) || sapi_not_null(body[@"errCode"])) {
                //code not null
                NSInteger code = sapi_not_null(body[@"errcode"]) ? [body[@"errcode"] integerValue] : sapi_not_null(body[@"code"]) ? [body[@"code"] integerValue] : sapi_not_null(body[@"errorno"]) ?  [body[@"errorno"] integerValue] : [body[@"errCode"] integerValue];
                if (code != 200 && code != 0) {
                    errorCode = code;
                }
            }
            errorMsg = sapi_not_null(body[@"errmsg"]) ? body[@"errmsg"] : sapi_not_null(body[@"msg"]) ? body[@"msg"] : sapi_not_null(body[@"errormsg"]) ? body[@"errormsg"] : sapi_not_null(body[@"errMsg"]) ? body[@"errMsg"] : nil;
        }
        if (errorCode > 0) {
            if (completion) {
                completion(response, errorCode, errorMsg);
            }
            return;
        }
        
        if([response.responseObject isKindOfClass:NSDictionary.class]){
            NSDictionary *body = response.responseObject;
            id data = sapi_not_null(body[@"data"]) ? body[@"data"] : sapi_not_null(body[@"ret"]) ? body[@"ret"] : nil;
            if (data != nil) {
                response = [[sNetworkResponse alloc] initWithResponse:response adpatedObject:data];
            }
        }
        if (completion) {
            completion(response, errorCode, errorMsg);
        }
    };
    return requestCompletion;
}

@end

@implementation sAPI

#pragma mark - Common API Properties

+ (void)buildCommon:(void (^)(sAPIBaseBuilder * _Nonnull baseBuilder))block {
    block([sAPIBaseBuilder shared]);
}

+ (void (^)(SAPISetParamsBlock _Nonnull))commonParams {
    return sAPIBaseBuilder.shared.commonParams;
}

+ (void (^)(SAPISetHeadersBlock _Nonnull))commonHeaders {
    return sAPIBaseBuilder.shared.commonHeaders;
}

+ (void (^)(NSString * _Nonnull))defaultHost {
    return sAPIBaseBuilder.shared.defaultHost;
}

+ (void (^)(sHTTPMethod))defaultMethod {
    return sAPIBaseBuilder.shared.defaultMethod;
}

#pragma mark - Instance API Properties

+ (sAPIBuilder *)build:(void (^)(sAPIBuilder * _Nonnull))block {
    sAPIBuilder *builder = [[sAPIBuilder alloc] init];
    if (block) {
        block(builder);
    }
    return builder;
}

+ (sAPIBuilder * _Nonnull (^)(NSString * _Nonnull))tag {
    return [[[sAPIBuilder alloc] init] tag];
}

+ (sAPIBuilder * _Nonnull (^)(sNetworkSub * _Nonnull))stubData {
    return [[[sAPIBuilder alloc] init] stubData];
}

+ (sAPIBuilder * _Nonnull (^)(NSDictionary * _Nonnull))params {
    return [[[sAPIBuilder alloc] init] params];
}

+ (sAPIBuilder * _Nonnull (^)(NSDictionary * _Nonnull))headers {
    return [[[sAPIBuilder alloc] init] headers];
}

+ (sAPIBuilder * _Nonnull (^)(sAPICommonParamsUsage))commonParamsUsage {
    return [[[sAPIBuilder alloc] init] commonParamsUsage];
}

+ (sAPIBuilder * _Nonnull (^)(sAPICommonHeadersUsage))commonHeadersUsage {
    return [[[sAPIBuilder alloc] init] commonHeadersUsage];
}

+ (sAPIBuilder * _Nonnull (^)(NSString * _Nonnull))host {
    return [[[sAPIBuilder alloc] init] host];
}

+ (sAPIBuilder * _Nonnull (^)(NSString * _Nonnull))path {
    return [[[sAPIBuilder alloc] init] path];
}

+ (sAPIBuilder * _Nonnull (^)(sHTTPMethod))method {
    return [[[sAPIBuilder alloc] init] method];
}

+ (sAPIBuilder * _Nonnull (^)(sParameterEncoding))encodingType {
    return [[[sAPIBuilder alloc] init] encodingType];
}

+ (sAPIBuilder * _Nonnull (^)(SAPIBeforeNetworkCallbackBlock _Nonnull))beforeNetworkCallback {
    return [[[sAPIBuilder alloc] init] beforeNetworkCallback];
}

@end
