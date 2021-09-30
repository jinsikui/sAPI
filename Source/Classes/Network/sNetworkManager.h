//
//  sNetworkManager.h
//  sRadio
//
//  Created by jinsikui on 2021/8/14.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sRequestConvertable.h"
#import "sNetworkResponse.h"
#import "sNetworkAdapter.h"
#import "sNetworkPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@class AFSecurityPolicy;
typedef NS_ENUM(NSInteger,sRequstTokenState){
    sRequstTokenStateRunning,
    sRequstTokenStateSuspended,
    sRequstTokenStateCanceling,
    sRequstTokenStateCompleted
};
/**
 请求创建后返回的透明类型
 */
@protocol sRequstToken <NSObject>
/**
 取消
 */
- (void)cancel;

/**
 继续执行
 */
- (void)resume;

/**
 挂起
 */
- (void)suspend;

/**
 任务所处状态
 */
@property (assign, nonatomic, readonly) sRequstTokenState state;

@end
typedef NSProgress * _Nullable  __autoreleasing * sNetworkResposeProgress;

typedef void (^sNetworkResposeComplete)(sNetworkResponse *  response);

@interface sNetworkManager : NSObject

/**
 单例
 */
+ (instancetype)shared;

/**
 新建一个实例
*/
+ (instancetype)manager;


/**
 根据sessionConfiguration配置一个实例
 */
- (instancetype)initWithConfiguraiton:(NSURLSessionConfiguration *)sessionConfiguration;


/**
 根据配置信息来创实例
 @param sessionConfiguration 配置信息
 @param trackRepeactRequest 是否要跟踪重复的请求（如果重复，不会进行第二次网络请求）
 */
- (instancetype)initWithConfiguraiton:(NSURLSessionConfiguration *)sessionConfiguration
                   trackRepeatRequest:(BOOL)trackRepeactRequest;


/**
 根据配置信息来创实例

 @param sessionConfiguration 配置信息
 @param requestAdapter 请求适配器
 @param urlAdapter URL适配器
 @param plugins 插件
 @param trackRepeactRequest 是否要跟踪重复的请求（如果重复，不会进行第二次网络请求）
 @return 实例
 */
- (instancetype)initWithConfiguraiton:(NSURLSessionConfiguration *)sessionConfiguration
                       requestAdapter:(id<sNetworkRequestAdapter> )requestAdapter
                           urlAdapter:(id<sNetworkURLAdapter> )urlAdapter
                              plugins:(NSArray<id<sNetworkPlugin>> * _Nullable)plugins
                    trackRepeatRequest:(BOOL)trackRepeactRequest;


/**
 发出一个网络请求

 @param requestable 请求
 @param proress 进度callback
 @param completion 完成回调
 @return 透明的可以取消的Token
 */
- (id<sRequstToken>)request:(id<sRequestConvertable>)requestable
                      progress:(sNetworkResposeProgress _Nullable )proress
                    completion:(sNetworkResposeComplete)completion;

/**
 发出一个网络请求
 
 @param requestable 请求
 @param completion 完成回调
 @return 透明的可以取消的Token
 */
- (id<sRequstToken>)request:(id<sRequestConvertable>)requestable
                    completion:(sNetworkResposeComplete)completion;


/**
 取消所有任务
 */
- (void)cancelAllOperations;

/**
 设置TLS握手过程中发生的授权处理
 */
- (void)setSecurityPolicy:(AFSecurityPolicy *)securityPolicy;
@end

NS_ASSUME_NONNULL_END
