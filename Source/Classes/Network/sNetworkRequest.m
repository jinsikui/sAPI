//
//  sNetworkRequest.m
//  sNetwork
//
//  Created by jinsikui on 2021/8/18.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import "sNetworkRequest.h"
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif
#import "sRequestType.h"
#import "sNetworkResponse.h"

@interface sNetworkRequest()

@property (strong, nonatomic, readwrite) NSMutableURLRequest * internalRequest;
@property (strong, nonatomic, readwrite) NSDictionary * finalBodyParams;
@property (strong, nonatomic, readwrite) id<sRequestConvertable> requestConvertable;
@end

@implementation sNetworkRequest

- (instancetype)initWithRequestConvertable:(id<sRequestConvertable>)requestConvertable
                           extraParameters:(NSDictionary *)extraParameters
                                     error:(NSError * _Nullable __autoreleasing *)error{
    if (requestConvertable == nil) {
        *error =  [NSError errorWithDomain:sNetworkErrorDomain
                                      code:-1000011
                                  userInfo:@{@"reason":@"nil input from network request"}];
        return nil;
    }
    if (self = [super init]) {
        self.requestConvertable = requestConvertable;
        self.internalRequest = [[self buildURLRequestWithConvertable:requestConvertable
                                                     extraParameters:extraParameters
                                                               error:error] mutableCopy];
    }
    return self;
}
- (instancetype)initWithRequestConvertable:(id<sRequestConvertable>)requestConvertable error:(NSError *__autoreleasing *)error{
    return [self initWithRequestConvertable:requestConvertable
                            extraParameters:nil
                                      error:error];
}

- (NSMutableURLRequest *)buildURLRequestWithConvertable:(id<sRequestConvertable>)requestConvertable
                                        extraParameters:(NSDictionary *)extraParameters
                                                  error:(NSError *__autoreleasing *)error{
    NSString * urlString = [requestConvertable.baseURL stringByAppendingString:requestConvertable.path];
    sHTTPMethod method = [requestConvertable respondsToSelector:@selector(httpMethod)] ? [requestConvertable httpMethod] : HTTP_GET;
    NSString * httpMethod = [self exactHTTPMethod:method];
    NSDictionary * parameters = [requestConvertable respondsToSelector:@selector(parameters)] ? requestConvertable.parameters : nil;
    if (extraParameters) {//有额外的参数
        if (parameters) {
            NSMutableDictionary * mutableDic = [[NSMutableDictionary alloc] initWithDictionary:parameters];
            for (NSDictionary * extraKey in extraParameters.allKeys) {
                id extraValue = [extraParameters objectForKey:extraKey];
                [mutableDic setObject:extraValue forKey:extraKey];
            }
            parameters = mutableDic;
        }else{
            parameters = extraParameters;
        }
    }
    NSURLRequest * request;
    sRequestType * requestType = [requestConvertable respondsToSelector:@selector(requestType)] ? [requestConvertable requestType] : [sRequestType data];
    BOOL isMultiFormData = NO;
    self.finalBodyParams = parameters;
    
    if ([requestType isKindOfClass:[sRequestTypeUpload class]]) {
        sRequestTypeUpload * upload = (sRequestTypeUpload *)requestType;
        isMultiFormData = upload.isMultiPartFormData;
    }
    if (isMultiFormData){
        request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:httpMethod
                                                                             URLString:urlString
                                                                            parameters:parameters
                                                             constructingBodyWithBlock:((sRequestTypeUpload *)requestType).constructingBodyBlock
                                                                                 error:error];
    }else{
        sParameterEncoding encoding = [requestConvertable respondsToSelector:@selector(encodingType)] ? [requestConvertable encodingType] : sParameterEncodingHTTP;
        switch (encoding) {
            case sParameterEncodingHTTP:
                request = [[AFHTTPRequestSerializer serializer] requestWithMethod:httpMethod
                                                                        URLString:urlString
                                                                       parameters:parameters
                                                                            error:error];
                break;
            case sParameterEncodingJSON:
                request = [[AFJSONRequestSerializer serializer] requestWithMethod:httpMethod
                                                                        URLString:urlString
                                                                       parameters:parameters
                                                                            error:error];
                break;
            case sParameterEncodingPropertyList:
                request = [[AFPropertyListRequestSerializer serializer] requestWithMethod:httpMethod
                                                                                URLString:urlString
                                                                               parameters:parameters
                                                                                    error:error];
                break;
            default:
                break;
        }
        
    }
    self.internalRequest = [request mutableCopy];
    [self.internalRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    if ([requestConvertable respondsToSelector:@selector(httpHeaders)]) {
        [[requestConvertable httpHeaders] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]) {
                [self.internalRequest setValue:obj forHTTPHeaderField:key];
            }
        }];
    }
    return self.internalRequest;
}


- (NSURLRequest *)urlRequest{
    return [self.internalRequest copy];
}

- (void)setParameterValue:(id)value forKey:(NSString *)key{
    
}

- (void)setQueryValue:(NSString *)value forName:(NSString *)name{
    NSURLComponents * components = [NSURLComponents componentsWithURL:_internalRequest.URL resolvingAgainstBaseURL:NO];
    NSMutableArray * queryItems = [[NSMutableArray alloc] initWithArray:components.queryItems];
    NSURLQueryItem * targetItem;
    for (NSURLQueryItem * item in queryItems) {
        if ([item.name isEqualToString:name]) {
            targetItem = item;
            break;
        }
    }
    if (targetItem) {
        [queryItems removeObject:targetItem];
    }
    targetItem = [[NSURLQueryItem alloc] initWithName:name value:value];
    [queryItems addObject:targetItem];
    components.queryItems = queryItems;
    self.internalRequest.URL = [components URL];
}

- (void)setValue:(id)value forHTTPHeaderField:(NSString *)field{
    [self.internalRequest setValue:value forHTTPHeaderField:field];
}

- (NSString *)exactHTTPMethod:(sHTTPMethod)method{
    switch (method) {
        case HTTP_GET:
            return  @"GET";
        case HTTP_POST:
            return  @"POST";
        case HTTP_PUT:
            return  @"PUT";
        case HTTP_HEAD:
            return @"HEAD";
        case HTTP_PATCH:
            return @"PATCH";
        case HTTP_TRACE:
            return @"TRACE";
        case HTTP_DELETE:
            return @"DELETE";
        case HTTP_CONNECT:
            return @"CONNECT";
        case HTTP_OPTIONS:
            return @"OPTIONS";
        default:
            break;
    }
    return nil;
}

@end

