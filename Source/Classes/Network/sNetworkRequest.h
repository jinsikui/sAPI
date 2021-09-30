//
//  sNetworkRequest.h
//  sNetwork
//
//  Created by jinsikui on 2021/8/18.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sRequestConvertable.h"

NS_ASSUME_NONNULL_BEGIN
/**
 网络请求的中间态，请求会按照Reqeustable -> NetworkRequest -> URLRequest -> URLSessionTask流进行转换
 */
@interface sNetworkRequest : NSObject

/**
 根据Requestable创建NetworkRequst
 */
- (instancetype )initWithRequestConvertable:(id<sRequestConvertable> )requestConvertable error:(NSError * *)error;

/**
 根据Requestable创建NetworkRequst,会对extraParameters进行遍历，如果原始parameters存在对应的key则覆盖，不存在则添加
 */
- (instancetype )initWithRequestConvertable:(id<sRequestConvertable> )requestConvertable
                            extraParameters:(NSDictionary * _Nullable)extraParameters
                                      error:(NSError * *)error;

/**
 对应的URLRequst请求
 */
@property (strong, nonatomic, readonly) NSURLRequest * urlRequest;

/**
 包含的requstable
 */
@property (strong, nonatomic, readonly) id<sRequestConvertable>  requestConvertable;

/**
 配置HTTP Headers
 */
- (void)setValue:(id )value forHTTPHeaderField:(nonnull NSString *)field;

/**
 修改Query中的key为指定的value,如果key不存在就添加一个query
 */
- (void)setQueryValue:(NSString *)value forName:(NSString *)name;

/**
 最后的请求的参数
 */
@property (nonatomic, readonly) NSDictionary * finalBodyParams;

@end

NS_ASSUME_NONNULL_END

