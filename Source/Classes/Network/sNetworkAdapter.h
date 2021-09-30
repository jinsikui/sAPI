//
//  sNetworkAdapter.h
//  sNetwork
//
//  Created by jinsikui on 2021/8/14.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sRequestConvertable.h"

@class sNetworkRequest;
NS_ASSUME_NONNULL_BEGIN

@protocol sNetworkRequestAdapter <NSObject>

/**
 适配方法，在这个方法里，把sRequestConvertable转换成sNetworkRequst

 @param requestConvertable 请求
 @param complete 当你完成了sRequestConvertable->sNetworkRequst转换后，执行complete闭包，如果出错传入Error对象，传入error对象后，网络请求不会继续进行
 */
- (void)adaptRequestConvertable:(id<sRequestConvertable>)requestConvertable
                       complete:(void(^)(sNetworkRequest *  request, NSError *  error))complete;

@end

@protocol sNetworkURLAdapter <NSObject>

/**
 适配方法，在这个方法里，把sNetworkRequest转换成NSURLRequest
 
 @param requset sNetworkRequest请求
 @param complete 当你完成了sNetworkRequest->NSURLRequest转换后，执行complete闭包，如果出错传入Error对象，传入error对象后，网络请求不会继续进行
 */
- (void)adaptRequest:(sNetworkRequest * )requset
            complete:(void(^)(NSURLRequest *  request,NSError * error))complete;

@end

/**
 默认的sNetworkRequst适配
 */
@interface sNetworkRequestDefaultAdapter : NSObject<sNetworkRequestAdapter>

- (void)adaptRequestConvertable:(id<sRequestConvertable> )requestConvertable
                       complete:(void(^)(sNetworkRequest *  request, NSError *  error))complete;

+ (instancetype)adapter;
@end

/**
 默认的URLRequest适配
 */
@interface sNetworkURLDefaultAdapter : NSObject <sNetworkURLAdapter>

- (void)adaptRequest:(sNetworkRequest * )requset
            complete:(void(^)(NSURLRequest *  request,NSError * error))complete;

+ (instancetype)adapter;

@end

NS_ASSUME_NONNULL_END
