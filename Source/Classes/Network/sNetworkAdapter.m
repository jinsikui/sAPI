//
//  sNetworkAdapter.m
//  sNetwork
//
//  Created by jinsikui on 2021/8/14.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import "sNetworkAdapter.h"
#import "sNetworkRequest.h"

@implementation sNetworkRequestDefaultAdapter

- (void)adaptRequestConvertable:(id<sRequestConvertable>)requestConvertable
                       complete:(void (^)(sNetworkRequest * ,NSError *  error))complete{
    NSError * error;
    sNetworkRequest * request = [[sNetworkRequest alloc]
                                  initWithRequestConvertable:requestConvertable
                                  error:&error];
    complete(request,error);
}

+ (instancetype)adapter{
    return [[sNetworkRequestDefaultAdapter alloc] init];
}

@end


@implementation sNetworkURLDefaultAdapter

+ (instancetype)adapter{
    return [[sNetworkURLDefaultAdapter alloc] init];
}
- (void)adaptRequest:(sNetworkRequest * )requset
            complete:(void(^)(NSURLRequest *  request,NSError * error))complete{
    NSURLRequest * urlRequest = requset.urlRequest;
    complete(urlRequest,nil);
}

@end
