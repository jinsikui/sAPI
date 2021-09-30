//
//  sNetworkSub.h
//  sNetwork
//
//  Created by jinsikui on 2021/8/14.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 网络请求的桩数据
 */
@interface sNetworkSub : NSObject

/**
 生成一个桩数据

 @param sampleData 模拟服务器返回的数据
 @param statusCode 状态码
 @param delay 延迟返回的时间
 @return 实例
 */
- (instancetype)initWithSampleData:(NSData *)sampleData statusCode:(NSInteger)statusCode delay:(NSTimeInterval)delay;

/**
 生成一个桩数据
 
 @param filePath 模拟服务器下载完成的文件路径
 @param statusCode 状态码
 @param delay 延迟返回的时间
 @return 实例
 */
- (instancetype)initWithSampleFilePath:(NSString *)filePath statusCode:(NSInteger)statusCode delay:(NSTimeInterval)delay;

/**
 根据JSON字典或者数组生成桩数据

 @param json JSON字典或者数组
 @param statusCode 状态码
 @param delay 延迟
 */
- (instancetype)initWithJson:(id)json statisCode:(NSInteger)statusCode delay:(NSTimeInterval)delay;
/**
 假的返回数据
 */
@property (nonatomic, strong, readonly) NSData * sampleData;

/**
 状态码
 */
@property (nonatomic, assign, readonly) NSInteger statusCode;

/**
 延迟返回的时间
 */
@property (nonatomic, assign, readonly) NSTimeInterval delay;


/**
 下载文件的文件路径
 */
@property (nonatomic, assign, readonly) NSString * filePath;

@end
