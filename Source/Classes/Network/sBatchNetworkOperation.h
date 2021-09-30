//
//  sBatchNetworkOperation.h
//  sNetwork
//
//  Created by jinsikui on 2021/8/18.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import "sNetworkAsyncOperation.h"
#import "sNetwork.h"
/**
 一组网络请求，只有请求都完成才会回调completion
 */
@interface sBatchNetworkOperation : sNetworkAsyncOperation

/**
 同一个对象不能被添加到Array里两次，否则会引起混乱
 */
- (instancetype)initWithRequestables:(NSArray *)requestables
                          completion:(void(^)(NSArray<sNetworkResponse *> *))completion;

- (instancetype)initWithRequestables:(NSArray *)requestables
                             manager:(sNetworkManager *)manager
                          completion:(void(^)(NSArray<sNetworkResponse *> *))completion;
@end
