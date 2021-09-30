//
//  sChainNetworkOperation.m
//  sNetwork
//
//  Created by jinsikui on 2021/8/18.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import "sChainNetworkOperation.h"
#import "sNetworkOperation.h"
#import <objc/runtime.h>

@interface sChainNetworkOperation()

@property (strong, nonatomic) NSArray * requestables;
@property (strong, nonatomic) sNetworkManager * manager;
@property (strong, nonatomic) void(^completion)(sNetworkResponse * lastActiveResponse);
@property (strong, nonatomic) NSString * udidKey;
@property (strong, nonatomic) sNetworkResponse * lastResponse;
@property (strong, nonatomic) NSOperationQueue * queue;
@end



@implementation sChainNetworkOperation

- (instancetype)initWithRequestables:(NSArray *)requestables completion:(void(^)(sNetworkResponse * lastActiveResponse))completion{
    return [self initWithRequestables:requestables
                              manager:[sNetworkManager manager]
                           completion:completion];
}
- (instancetype)initWithRequestables:(NSArray *)requestables
                             manager:(sNetworkManager *)manager
                          completion:(void(^)(sNetworkResponse * lastActiveResponse))completion{
    if (self = [super init]) {
        self.requestables = requestables;
        self.manager = manager;
        self.completion = completion;
        self.udidKey = [[NSUUID UUID] UUIDString];
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)execute{
    NSBlockOperation * finishOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completion) {
                self.completion(self.lastResponse);
            }
        });
        [self finishOperation];
    }];
    [self.requestables enumerateObjectsUsingBlock:^(id<sRequestConvertable> requestable, NSUInteger idx, BOOL * _Nonnull stop) {
        objc_setAssociatedObject(requestable, [self.udidKey UTF8String], @(idx), OBJC_ASSOCIATION_RETAIN);
        sNetworkOperation * operation = [[sNetworkOperation alloc] initWithRequestable:requestable
                                                                                 manager:self.manager
                                                                              completion:^(sNetworkResponse * response) {
                                                                                  if (response.error) {//请求失败，取消全部任务
                                                                                      if(self.completion){
                                                                                          self.completion(response);
                                                                                      }
                                                                                      [self.queue cancelAllOperations];
                                                                                  }else{
                                                                                      if ([requestable conformsToProtocol:@protocol(sChainRequestable)]) {
                                                                                          id<sChainRequestable> chainRequest = (id)requestable;
                                                                                          NSError * error;
                                                                                          BOOL shouldStartNext = [chainRequest shouldStartNextWithResponse:response error:&error];
                                                                                          if (!shouldStartNext) {
                                                                                              if (!error) {
                                                                                                  error = [NSError errorWithDomain:sNetworkErrorDomain
                                                                                                                              code:-1000010
                                                                                                                          userInfo:@{@"Reason":@"Chain request decide not to contine"}];
                                                                                              }
                                                                                              sNetworkResponse * adaptedResponse = [[sNetworkResponse alloc] initWithResponse:response udpatedError:error];
                                                                                              if(self.completion){
                                                                                                  self.completion(adaptedResponse);
                                                                                              }
                                                                                              [self.queue cancelAllOperations];
                                                                                          }else{
                                                                                              self.lastResponse = response;
                                                                                          }
                                                                                      }else{
                                                                                          self.lastResponse = response;
                                                                                      }
                                                                                  }
                                                                              }];
        [self.queue addOperation:operation];
    }];
    [self.queue addOperation:finishOperation];
}

- (void)cancel{
    [self.queue cancelAllOperations];
    [super cancel];
}

@end
