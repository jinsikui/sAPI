//
//  sNetworkResponse.h
//  sNetwork
//
//  Created by jinsikui on 2021/8/14.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sRequestConvertable.h"

@protocol sRequestConvertable;

extern NSString * const sNetworkErrorDomain;

typedef NS_ENUM(NSInteger, sNetworkErrorCode){
    sNetworkErrorCanceled = -400001, //请求被取消
    sNetworkErrorFailToAdaptsNetworkRequest = -400002, //从Requstable -> sNeworkRequest转换失败
    sNetworkErrorFailToAdaptURLRequest = -400003, //从sNeworkRequest -> URLRequst转换失败
    sNetworkErrorFailToAdaptedResponse = -400005,//请求的-[sRequestConvertable adaptResponse:]适配失败
};


/**
 响应对象的来源

 - sNetworkResponseSourceStub: 由假数据返回，假数据由Requestable提供
 - sNetworkResponseSourceLocalCache: 由本地缓存提供
 - sNetworkResponseSourceURLLoadingSystem: 由URL Loading System提供
 */
typedef NS_ENUM(NSInteger, sNetworkResponseSource){
    sNetworkResponseSourceStub,
    sNetworkResponseSourceLocalCache,
    sNetworkResponseSourceURLLoadingSystem
};

/**
   网络请求返回给上层的对象
 */
@interface sNetworkResponse<T> : NSObject

/**
 网络请求返回的对象，默认当作JSON解析的，这个对象是经过Requestable适配后的对象
 */
@property (strong, nonatomic, readonly) T responseObject;

/**
 网络请求的HTTP Response
 */
@property (strong, nonatomic, readonly) NSURLResponse * urlResponse;

/**
 网络请求的错误，没有Error说明请求成功
 */
@property (strong, nonatomic, readonly) NSError * error;

/**
 状态码
 */
@property (assign, nonatomic,readonly) NSInteger statusCode;

/**
 原始的请求
 */
@property (strong, nonatomic,readonly) id <sRequestConvertable> requestConvertable;

/**
 下载文件的路径（只有download任务有效）
 */
@property (strong, nonatomic, readonly) NSURL * filePath;

/**
 数据的来源
 */
@property (assign, nonatomic, readonly) sNetworkResponseSource source;

- (instancetype)initWithRequest:(id<sRequestConvertable>)request
                    urlResponse:(NSURLResponse *)urlResponse
                   responseData:(NSData *)data
                          error:(NSError *)error;


- (instancetype)initWithRequest:(id<sRequestConvertable>)request
                    urlResponse:(NSURLResponse *)urlResponse
                       filePath:(NSURL *)filePath
                          error:(NSError *)error;


- (instancetype)initWithRequest:(id<sRequestConvertable>)request
                    urlResponse:(NSURLResponse *)urlResponse
                   responseData:(NSData *)data
                          error:(NSError *)error
                         source:(sNetworkResponseSource)source;

- (instancetype)initWithRequest:(id<sRequestConvertable>)request
                    urlResponse:(NSURLResponse *)urlResponse
                       filePath:(NSURL *)filePath
                          error:(NSError *)error
                         source:(sNetworkResponseSource)source;


- (instancetype)initStubResponseWithRequest:(id<sRequestConvertable>)request data:(sNetworkSub *)data;

- (instancetype)initWithResponse:(sNetworkResponse *)response adpatedObject:(id)object;
- (instancetype)initWithResponse:(sNetworkResponse *)response udpatedError:(NSError *)error;
@end
