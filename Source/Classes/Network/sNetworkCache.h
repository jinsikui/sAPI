//
//  sNetworkCache.h
//  sNetwork
//
//  Created by jinsikui on 2021/8/14.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sNetworkCacheItem : NSObject

@property (strong, nonatomic) NSData * data;

@property (strong, nonatomic) NSURLResponse * httpResponse;

@end
/**
 缓存逻辑，在Cache目录建立子文件夹sNetworkCache，含有两个字文件目录，MetaData（存储元数据），Data（存储网络缓存数据）。
 
 清理缓存的时候，遍历元数据文件，然后删除对应的Data文件
 */
@interface sNetworkCache : NSObject


/**
 保存缓存数据，这个方法立即返回，并在后台线程上对数据进行存储

 @param data 数据
 @param urlRequst 请求
 @param expire 过期时间
 */
+ (void)saveCache:(NSData *)data
       forRequset:(NSURLRequest *)urlRequst
     httpResponse:(NSURLResponse*)httpResponse
           expire:(NSTimeInterval)expire;

/**
 获取存储的缓存数据

 @param urlRequst URLRequst请求
 @param expire 有效时间，单位秒（相对于缓存事件），比如缓存是11:30:00产生的，expire是30，那么11:30:31秒后缓存失效
 @return 缓存的数据，可能为空
 */
+ (sNetworkCacheItem *)cachedDataForRequest:(NSURLRequest *)urlRequst expire:(NSTimeInterval)expire;

/**
 删除全部缓存
 */
+ (void)clearAllCachedFiles;

/**
 全部缓存文件大小
 */
+ (NSString *)cachedSize;

/**
  清理过期的数据
 */
+ (void)clearExpireCachedData;
@end
