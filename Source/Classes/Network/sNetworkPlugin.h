//
//  sNetworkPlugin.h
//  sNetwork
//
//  Created by jinsikui on 2021/10/19.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sNetworkRequest.h"
#import "sNetworkResponse.h"

NS_ASSUME_NONNULL_BEGIN
/**
 网络框架插件，注意插件的代理方法往往不在主线程执行
 */
@protocol sNetworkPlugin<NSObject>

@optional

/**
 将要开始适配convertable，即convertable->sNetworkRequest的转化
 */
- (void)willAdaptRequestConvertable:(id<sRequestConvertable>)convertable;

/**
 完成适配convertable，即convertable->sNetworkRequest的转化
 */
- (void)didAdaptedRequestConvertable:(id<sRequestConvertable>)convertable
                          withResult:(sNetworkRequest *)request
                               error:(NSError *)error;
/**
 将要开始适配request，即request->URLRequest的转化
 */
- (void)willAdaptRequest:(sNetworkRequest *)request;

/**
 完成开始适配request，即request->URLRequest的转化
 */
- (void)didAdaptedRequest:(sNetworkRequest *)request 
               withResult:(NSURLRequest *)urlRequest
                    error:(NSError *)error;
/**
 收到AFN的原始数据
 */
- (void)didReceiveResponse:(NSURLResponse *)response
            responseObject:(id _Nullable)responseObject
                  filePath:(NSURL * _Nullable)filePath
                     error:(NSError *)error;
/**
 将要进行返回对象的适配
 */
- (void)willAdaptResponse:(sNetworkResponse *)response;

/**
 完成返回对象的适配
 */
- (void)didAdaptedResponse:(sNetworkResponse *)responser;

@end

NS_ASSUME_NONNULL_END
