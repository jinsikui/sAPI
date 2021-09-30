//
//  sNetworkOperation.h
//  sNetwork
//
//  Created by jinsikui on 2021/8/18.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import "sNetworkAsyncOperation.h"
#import "sNetwork.h"
#
@interface sNetworkOperation : sNetworkAsyncOperation

- (instancetype)initWithRequestable:(id<sRequestConvertable>)requestable completion:(void(^)(sNetworkResponse *))completion;

- (instancetype)initWithRequestable:(id<sRequestConvertable>)requestable manager:(sNetworkManager *)manager completion:(void(^)(sNetworkResponse *))completion;
@end
