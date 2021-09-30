//
//  sNetworkAsyncOperation.m
//  sNetwork
//
//  Created by jinsikui on 2021/8/18.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import "sNetworkAsyncOperation.h"

typedef NS_ENUM(NSInteger, sNetworkAsyncOperationState){
    sNetworkAsyncOperationStatePaused,
    sNetworkAsyncOperationStateReady,
    sNetworkAsyncOperationStateExecuting,
    sNetworkAsyncOperationStateFinished,
};

static inline BOOL sN_StateTransitionValid(sNetworkAsyncOperationState fromState,sNetworkAsyncOperationState toState, BOOL isCancelled){
    switch (fromState) {
        case sNetworkAsyncOperationStateReady:
            switch (toState) {
                case sNetworkAsyncOperationStatePaused:
                case sNetworkAsyncOperationStateExecuting:
                    return YES;
                case sNetworkAsyncOperationStateFinished:
                    return isCancelled;
                default:
                    return NO;
            }
        case sNetworkAsyncOperationStateExecuting:
            switch (toState) {
                case sNetworkAsyncOperationStatePaused:
                case sNetworkAsyncOperationStateFinished:
                    return YES;
                default:
                    return NO;
            }
        case sNetworkAsyncOperationStateFinished:
            return NO;
        case sNetworkAsyncOperationStatePaused:
            return toState == sNetworkAsyncOperationStateFinished || toState == sNetworkAsyncOperationStateExecuting;
    }
}

static inline NSString * sN_KeyPathForOperationState(sNetworkAsyncOperationState state){
    switch (state) {
        case sNetworkAsyncOperationStateReady:
            return @"isReady";
            break;
        case sNetworkAsyncOperationStatePaused:
            return @"isPaused";
        case sNetworkAsyncOperationStateExecuting:
            return @"isExecuting";
        
        case sNetworkAsyncOperationStateFinished:
            return @"isFinished";
    }
}


@interface sNetworkAsyncOperation()

@property (assign, nonatomic) sNetworkAsyncOperationState state;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

@end

@implementation sNetworkAsyncOperation

- (instancetype)init{
    if (self = [super init]) {
        _lock = [[NSRecursiveLock alloc] init];
        _state = sNetworkAsyncOperationStateReady;
    }
    return self;
}
- (void)start{
    if ([self isCancelled]) {
        self.state = sNetworkAsyncOperationStateFinished;
        return;
    }
    self.state = sNetworkAsyncOperationStateExecuting;
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
}

- (void)setState:(sNetworkAsyncOperationState)state{
    if (!sN_StateTransitionValid(_state, state, [self isCancelled])) {
        return;
    }
    [self.lock lock];
    NSString * oldStateKey =  sN_KeyPathForOperationState(_state);
    NSString * newStateKey =  sN_KeyPathForOperationState(state);
    [self willChangeValueForKey:newStateKey];
    [self willChangeValueForKey:oldStateKey];
    _state = state;
    [self didChangeValueForKey:oldStateKey];
    [self didChangeValueForKey:newStateKey];
    [self.lock unlock];
}

- (void)main{
    if ([self isCancelled]) {
        self.state = sNetworkAsyncOperationStateFinished;
        return;
    }
    [self execute];
}

#pragma mark - API

- (void)pause{
    if ([self isPaused] || [self isCancelled] || [self isFinished]) {
        return;
    }
    self.state = sNetworkAsyncOperationStatePaused;
}

- (void)resume{
    if (![self isPaused]) {
        return;
    }
    self.state = sNetworkAsyncOperationStateExecuting;
}

- (void)execute{}

- (void)finishOperation{
    self.state = sNetworkAsyncOperationStateFinished;
}

- (void)cancel{
    self.state = sNetworkAsyncOperationStateFinished;
    [super cancel];
}

#pragma mark - Life Circle

- (BOOL)isPaused {
    return self.state == sNetworkAsyncOperationStatePaused;
}

- (BOOL)isReady{
    return self.state == sNetworkAsyncOperationStateReady && [super isReady];
}

- (BOOL)isConcurrent{
    return YES;
}

- (BOOL)isFinished{
    return self.state == sNetworkAsyncOperationStateFinished;
}

- (BOOL)isExecuting{
    return self.state == sNetworkAsyncOperationStateExecuting;
}
- (BOOL)isAsynchronous{
    return YES;
}

@end
