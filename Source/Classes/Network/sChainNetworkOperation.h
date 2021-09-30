//
//  sChainNetworkOperation.h
//  sNetwork
//
//  Created by jinsikui on 2021/8/18.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import "sNetworkAsyncOperation.h"
#import "sNetwork.h"

@protocol  sChainRequestable <sRequestConvertable>

/**
 收到了上一个网络请求的完成回调，在这里决定是否要继续进行下一个网络请求

 */
- (BOOL)shouldStartNextWithResponse:(sNetworkResponse *)response error:(NSError **)error;

@end

@interface sChainNetworkOperation : sNetworkAsyncOperation

/**
 同一个对象不能被添加到Array里两次，否则会引起混乱
 */
- (instancetype)initWithRequestables:(NSArray *)requestables
                          completion:(void(^)(sNetworkResponse * lastActiveResponse))completion;

- (instancetype)initWithRequestables:(NSArray *)requestables
                             manager:(sNetworkManager *)manager
                          completion:(void(^)(sNetworkResponse * lastActiveResponse))completion;

@end
