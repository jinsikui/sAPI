//
//  sNetworkOperation.m
//  sNetwork
//
//  Created by jinsikui on 2021/8/18.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import "sNetworkOperation.h"

@interface sNetworkOperation()

@property (strong, nonatomic) id<sRequestConvertable> requestable;

@property (copy, nonatomic) void (^completion)(sNetworkResponse *);

@property (strong, nonatomic) sNetworkManager * manager;

@property (strong, nonatomic) id<sRequstToken> token;
@end

@implementation sNetworkOperation

- (instancetype)initWithRequestable:(id<sRequestConvertable>)requestable completion:(void (^)(sNetworkResponse *))completion{
    return [self initWithRequestable:requestable
                             manager:[sNetworkManager manager]
                          completion:completion];
}

- (instancetype)initWithRequestable:(id<sRequestConvertable>)requestable
                            manager:(sNetworkManager *)manager
                         completion:(void (^)(sNetworkResponse *))completion{
    if (self = [super init]) {
        self.requestable = requestable;
        self.completion = completion;
        self.manager = manager;
    }
    return self;
}

- (void)pause{
    [self.token suspend];
    [super pause];
}

- (void)resume{
    [self.token resume];
    [super resume];
}

- (void)execute{
    self.token = [self.manager request:self.requestable
                            completion:^(sNetworkResponse * _Nonnull response) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    self.completion(response);
                                });
                                [self finishOperation];
                            }];
}

- (void)cancel{
    if (self.token) {
        [self.token cancel];
    }
    [super cancel];
}

@end
