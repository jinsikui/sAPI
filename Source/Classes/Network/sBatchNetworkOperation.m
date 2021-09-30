//
//  sBatchNetworkOperation.m
//  sNetwork
//
//  Created by jinsikui on 2021/8/18.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import "sBatchNetworkOperation.h"
#import <objc/runtime.h>
#import "sNetworkOperation.h"

@interface sBatchNetworkOperation()

@property (strong, nonatomic) NSArray * requestables;
@property (strong, nonatomic) sNetworkManager * manager;
@property (strong, nonatomic) void(^completion)(NSArray<sNetworkResponse *> *);
@property (strong, nonatomic) NSString * udidKey;
@property (strong, nonatomic) NSMutableArray * receiveResponses;
@property (strong, nonatomic) NSOperationQueue * queue;
@end

@implementation sBatchNetworkOperation

- (instancetype)initWithRequestables:(NSArray *)requestables completion:(void (^)(NSArray<sNetworkResponse *> *))completion{
    return [self initWithRequestables:requestables
                              manager:[sNetworkManager manager]
                           completion:completion];
}
- (instancetype)initWithRequestables:(NSArray *)requestables
                             manager:(sNetworkManager *)manager
                          completion:(void (^)(NSArray<sNetworkResponse *> *))completion{
    if (self = [super init]) {
        self.requestables = requestables;
        self.manager = manager;
        self.completion = completion;
        self.udidKey = [[NSUUID UUID] UUIDString];
        self.receiveResponses = [[NSMutableArray alloc] initWithCapacity:requestables.count];
        for (NSInteger i = 0; i < requestables.count; i ++) {
            [self.receiveResponses addObject:@(0)];//占位符
        }
        self.queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)execute{
    NSBlockOperation * finishOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.completion) { //检查数据是否被Canceled，cancel不会给上层回调
                BOOL isValid = YES;
                for (sNetworkResponse * resp in self.receiveResponses) {
                    if (![resp isKindOfClass:[sNetworkResponse class]]) {
                        isValid = NO;
                        break;
                    }
                }
                if (!isValid) {
                    return;
                }
                self.completion(self.receiveResponses);
            }
        });
        [self finishOperation];
    }];
    __block NSMutableArray * operations = [NSMutableArray new];
    [self.requestables enumerateObjectsUsingBlock:^(id<sRequestConvertable> requestable, NSUInteger idx, BOOL * _Nonnull stop) {
        objc_setAssociatedObject(requestable, [self.udidKey UTF8String], @(idx), OBJC_ASSOCIATION_RETAIN);
        sNetworkOperation * operation = [[sNetworkOperation alloc] initWithRequestable:requestable
                                                                                 manager:self.manager
                                                                              completion:^(sNetworkResponse * response) {
                                                                                  [self updateCallbacksWithResponse:response];
                                                                              }];
        [finishOperation addDependency:operation];
        [operations addObject:operation];
    }];
    [operations enumerateObjectsUsingBlock:^(NSOperation * operation, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.queue addOperation:operation];
    }];
    [self.queue addOperation:finishOperation];
}

- (void)updateCallbacksWithResponse:(sNetworkResponse *)response{
    @synchronized (self) {
        NSNumber * idx = objc_getAssociatedObject(response.requestConvertable, [self.udidKey UTF8String]);
        [self.receiveResponses replaceObjectAtIndex:idx.integerValue withObject:response];
    }
}
- (void)cancel{
    [self.queue cancelAllOperations];
    [super cancel];
}
@end
