//
//  sNetworkResponse.m
//  sNetwork
//
//  Created by jinsikui on 2021/8/14.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import "sNetworkResponse.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

NSString * const sNetworkErrorDomain = @"com.s.network.error";

@interface sNetworkResponse()

@property (strong, nonatomic, readwrite)NSData * originalData;

@property (strong, nonatomic, readwrite) id responseObject;

@property (strong, nonatomic, readwrite) NSURLResponse * urlResponse;

@property (strong, nonatomic, readwrite) NSError * error;

@property (strong, nonatomic, readwrite) NSURL * filePath;

@property (strong, nonatomic, readwrite) id <sRequestConvertable> requestConvertable;

@property (assign, nonatomic, readwrite) sNetworkResponseSource source;

@property (assign, nonatomic, readwrite) NSInteger statusCode;

@end

@implementation sNetworkResponse

- (instancetype)initWithResponse:(sNetworkResponse *)response udpatedError:(NSError *)error{
    if (self = [super init]) {
        self.originalData = response.originalData;
        self.responseObject = response.responseObject;
        self.urlResponse = response.urlResponse;
        self.error = error;
        self.filePath = response.filePath;
        self.source = response.source;
        self.statusCode = response.statusCode;
        self.requestConvertable = response.requestConvertable;
    }
    return self;
}

- (instancetype)initWithResponse:(sNetworkResponse *)response adpatedObject:(id)object{
    if (self = [super init]) {
        self.originalData = response.originalData;
        self.responseObject = object;
        self.urlResponse = response.urlResponse;
        self.error = response.error;
        self.filePath = response.filePath;
        self.source = response.source;
        self.statusCode = response.statusCode;
        self.requestConvertable = response.requestConvertable;
    }
    return self;
}
- (instancetype)initWithRequest:(id<sRequestConvertable>)request
                    urlResponse:(NSURLResponse *)urlResponse
                   responseData:(NSData *)data
                          error:(NSError *)error{
    return [self initWithRequest:request
                     urlResponse:urlResponse
                    responseData:data
                           error:error
                          source:sNetworkResponseSourceURLLoadingSystem];
}

- (instancetype)initWithRequest:(id<sRequestConvertable>)request
                    urlResponse:(NSURLResponse *)urlResponse
                       filePath:(NSURL *)filePath
                          error:(NSError *)error{
    return [self initWithRequest:request
                     urlResponse:urlResponse
                        filePath:filePath
                           error:error
                          source:sNetworkResponseSourceURLLoadingSystem];
}

- (instancetype)initWithRequest:(id<sRequestConvertable>)request
                    urlResponse:(NSURLResponse *)urlResponse
                       filePath:(NSURL *)filePath error:(NSError *)error
                         source:(sNetworkResponseSource)source{
    if (self = [super init]) {
        self.filePath = filePath;
        self.urlResponse = urlResponse;
        self.requestConvertable = request;
        self.error = error;
        self.source = source;
        if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse * httpResp = (NSHTTPURLResponse *)urlResponse;
            self.statusCode = httpResp.statusCode;
        }else{
            self.statusCode = -1;
        }
    }
    return self;
}

- (instancetype)initWithRequest:(id<sRequestConvertable>)request
                    urlResponse:(NSURLResponse *)urlResponse
                   responseData:(NSData *)data
                          error:(NSError *)error
                         source:(sNetworkResponseSource)source{
    if (self = [super init]) {
        self.originalData = data;
        self.urlResponse = urlResponse;
        self.requestConvertable = request;
        self.error = error;
        self.source = source;
        if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse * httpResp = (NSHTTPURLResponse *)urlResponse;
            self.statusCode = httpResp.statusCode;
        }else{
            self.statusCode = -1;
        }
        [self decodeResponse];
        BOOL responseValid = YES;
        NSError * validError;
        if ([request respondsToSelector:@selector(responseValider)]) {
            id<sNetworkResponseValider> valider = [request responseValider];
            responseValid = [valider validResponse:self.responseObject error:&validError];
        }
        if (!responseValid) {//验证失败
            if (!validError) {
                NSString * reason = [NSString stringWithFormat:@"Failed to valid the response with UnKnown error"];
                NSDictionary * userInfo = @{@"InvalidReason":reason};
                validError = [NSError errorWithDomain:sNetworkResponseValiderErrorDomain
                                                 code:-1
                                             userInfo:userInfo];
            }
            self.error = validError;
            self.responseObject = nil;
        }
    }
    return self;
}

- (instancetype)initStubResponseWithRequest:(id<sRequestConvertable>)request data:(sNetworkSub *)data{
    if (self = [super init]) {
        self.requestConvertable = request;
        self.error = nil;
        self.source = sNetworkResponseSourceStub;
        self.originalData = data.sampleData;
        self.statusCode = data.statusCode;
        [self decodeResponse];
    }
    return self;
}
- (void)decodeResponse{
    sResponseDecncoding decodeType = [self.requestConvertable respondsToSelector:@selector(decodingType)] ? [self.requestConvertable decodingType] : sResponseDecncodingJSON;
    BOOL removesKeysWithNullValues = [self.requestConvertable respondsToSelector:@selector(removesKeysWithNullValues)] ? [self.requestConvertable removesKeysWithNullValues] : NO;
    AFHTTPResponseSerializer * decoder;
    switch (decodeType) {
        case sResponseDecncodingHTTP:
            decoder = [AFHTTPResponseSerializer serializer];
            break;
        case sResponseDecncodingJSON:{
            AFJSONResponseSerializer * serializer = [AFJSONResponseSerializer serializer];
            serializer.removesKeysWithNullValues = removesKeysWithNullValues;
            decoder = [AFJSONResponseSerializer serializer];
        }
            break;
        case sResponseDecncodingXML:
            decoder = [AFXMLParserResponseSerializer serializer];
            break;
        default:
            break;
    }
    NSError * error;
    if ([self.requestConvertable respondsToSelector:@selector(acceptableContentTypes)]) {
        NSSet * acceptableContentTypes = [self.requestConvertable acceptableContentTypes];
        decoder.acceptableContentTypes = acceptableContentTypes;
    }
    self.responseObject = [decoder responseObjectForResponse:self.urlResponse
                                                        data:self.originalData
                                                       error:&error];
    if (error) {
        self.error = error;
    }
}

@end
