//
//  sNetworkManager.m
//  sRadio
//
//  Created by jinsikui on 2021/8/14.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import "sNetworkManager.h"
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif
#import "sNetworkAdapter.h"
#import "NSURLRequest+sNetwork.h"
#import "sNetworkCache.h"

typedef void(^sAFDataTaskCompletionBlock)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error);
typedef void(^sAFDownloadTaskCompletionBlock)(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error);;

#define BEGIN_ASYNC_MANAGER_QUEUE dispatch_async(self.queue, ^{
#define END_ASYNC_MANAGER_QUEU });

#define BEGIN_ASYNC_MAIN_QUEUE dispatch_async(dispatch_get_main_queue(), ^{
#define END_ASYNC_MAIN_QUEU });

@interface sRequstToken : NSObject <sRequstToken>

+ (instancetype)token;

@property (strong, nonatomic) NSURLSessionTask * task;
@property (assign, nonatomic) BOOL isCanceled;

@end

@interface sRequstToken()

@end

@implementation sRequstToken

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isCanceled = NO;
    }
    return self;
}
- (sRequstTokenState)state{
    switch (self.task.state) {
        case NSURLSessionTaskStateRunning:
            return sRequstTokenStateRunning;
        case NSURLSessionTaskStateCanceling:
            return sRequstTokenStateCanceling;
        case NSURLSessionTaskStateCompleted:
            return sRequstTokenStateCompleted;
        case NSURLSessionTaskStateSuspended:
            return sRequstTokenStateSuspended;
    }
}

- (void)suspend{
    [self.task suspend];
}

- (void)resume{
    [self.task resume];
}

- (void)cancel{
    [self.task cancel];
    _isCanceled = YES;
}

+ (instancetype)token{
    return [[sRequstToken alloc] init];
}

@end



@interface sNetworkManager()

@property (strong, nonatomic) NSRecursiveLock * lock;

@property (strong, nonatomic) id<sNetworkRequestAdapter> requestAdapter;

@property (strong, nonatomic) id<sNetworkURLAdapter> urlAdapter;

@property (strong, nonatomic) AFURLSessionManager * afSessionManager;

@property (strong, nonatomic) dispatch_queue_t queue;

@property (assign, nonatomic, readonly) BOOL trackRepeatRequest;

@property (strong, nonatomic) NSMutableDictionary * callbackMap;//URLRequst -> CallBcaks

@property (strong, nonatomic) NSArray * plugins;

@end

@implementation sNetworkManager

- (void)setSecurityPolicy:(AFSecurityPolicy *)securityPolicy{
    self.afSessionManager.securityPolicy = securityPolicy;
}

- (void)cancelAllOperations{
    [self.lock lock];
    [self.afSessionManager.operationQueue cancelAllOperations];
    self.callbackMap = [NSMutableDictionary new];
    [self.lock unlock];
}
- (void)pauseAllOpertaions{
    [self.lock lock];
    
}
+ (instancetype)shared{
    static sNetworkManager * _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [sNetworkManager manager];
    });
    return _instance;
}
+ (instancetype)manager{
    return [[sNetworkManager alloc] initWithConfiguraiton:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (instancetype)initWithConfiguraiton:(NSURLSessionConfiguration *)sessionConfiguration
                       requestAdapter:(id<sNetworkRequestAdapter> )requestAdapter
                           urlAdapter:(id<sNetworkURLAdapter> )urlAdapter
                              plugins:(NSArray<id<sNetworkPlugin>> *)plugins
                   trackRepeatRequest:(BOOL)trackRepeactRequest{
    NSParameterAssert(sessionConfiguration != nil);
    NSParameterAssert(requestAdapter != nil && [requestAdapter conformsToProtocol:@protocol(sNetworkRequestAdapter)]);
    NSParameterAssert(urlAdapter != nil && [urlAdapter conformsToProtocol:@protocol(sNetworkURLAdapter)]);
    if (self = [super init]) {
        self.requestAdapter = requestAdapter;
        self.urlAdapter = urlAdapter;
        //iOS 11.3的某些机型上，设置cache会造成无限crash
        sessionConfiguration.URLCache = nil;
        self.afSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
        self.afSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.queue = dispatch_queue_create("com.snetwork.sessionManager.queue", DISPATCH_QUEUE_SERIAL);
        _trackRepeatRequest = trackRepeactRequest;
        if (self.trackRepeatRequest) {
            self.callbackMap = [NSMutableDictionary new];
        }
        self.plugins = plugins;
        self.lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}
- (instancetype)initWithConfiguraiton:(NSURLSessionConfiguration *)sessionConfiguration
                   trackRepeatRequest:(BOOL)trackRepeactRequest{
    sNetworkRequestDefaultAdapter * requestAdapter = [[sNetworkRequestDefaultAdapter alloc] init];
    sNetworkURLDefaultAdapter * urlAdapter = [[sNetworkURLDefaultAdapter alloc] init];
    return [self initWithConfiguraiton:sessionConfiguration
                        requestAdapter:requestAdapter
                            urlAdapter:urlAdapter
                               plugins:nil
                    trackRepeatRequest:trackRepeactRequest];
}
- (instancetype)initWithConfiguraiton:(NSURLSessionConfiguration *)sessionConfiguration{
    sNetworkRequestDefaultAdapter * requestAdapter = [[sNetworkRequestDefaultAdapter alloc] init];
    sNetworkURLDefaultAdapter * urlAdapter = [[sNetworkURLDefaultAdapter alloc] init];
    return [self initWithConfiguraiton:sessionConfiguration
                        requestAdapter:requestAdapter
                            urlAdapter:urlAdapter
                               plugins:nil
                    trackRepeatRequest:NO];
}

- (id<sRequstToken>)request:(id<sRequestConvertable>)requestConvertable
     completion:(void (^)(sNetworkResponse * _Nonnull))completion{
    return [self request:requestConvertable
                progress:nil
              completion:completion];
}

- (id<sRequstToken>)request:(id<sRequestConvertable>)requestConvertable
                   progress:(sNetworkResposeProgress )progress
                 completion:(sNetworkResposeComplete)completion{
    NSParameterAssert(requestConvertable != nil);
    sRequstToken * token = [sRequstToken token];
    //Plugins
    for (id<sNetworkPlugin> plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(willAdaptRequestConvertable:)]) {
            [plugin willAdaptRequestConvertable:requestConvertable];
        }
    }
    [self.requestAdapter adaptRequestConvertable:requestConvertable
                                        complete:^(sNetworkRequest * _Nonnull request, NSError * _Nonnull error) {
                                            //Plugins
                                            for (id<sNetworkPlugin> plugin in self.plugins) {
                                                if ([plugin respondsToSelector:@selector(didAdaptedRequestConvertable:withResult:error:)]) {
                                                    [plugin didAdaptedRequestConvertable:requestConvertable withResult:request error:error];
                                                }
                                            }
                                            if (error) {
                                                [self envokeCompletion:completion withError:error request:requestConvertable];
                                                return;
                                            }
                                            if (token.isCanceled) {
                                                NSError * error = [NSError errorWithDomain:sNetworkErrorDomain
                                                                                      code:sNetworkErrorCanceled
                                                                                  userInfo:nil];
                                                [self envokeCompletion:completion withError:error request:requestConvertable];
                                                return;
                                            }
                                            if (request == nil) {
                                                NSError * error = [NSError errorWithDomain:sNetworkErrorDomain
                                                                                      code:sNetworkErrorFailToAdaptsNetworkRequest
                                                                                  userInfo:nil];
                                                [self envokeCompletion:completion withError:error request:requestConvertable];
                                                return;
                                            }
                                            //Plugins
                                            for (id<sNetworkPlugin> plugin in self.plugins) {
                                                if ([plugin respondsToSelector:@selector(willAdaptRequest:)]) {
                                                    [plugin willAdaptRequest:request];
                                                }
                                            }
                                            [self.urlAdapter adaptRequest:request
                                                                 complete:^(NSURLRequest * _Nonnull urlRequest, NSError * _Nonnull error) {
                                                                     //Plugins
                                                                     for (id<sNetworkPlugin> plugin in self.plugins) {
                                                                         if ([plugin respondsToSelector:@selector(didAdaptedRequest:withResult:error:)]) {
                                                                             [plugin didAdaptedRequest:request withResult:urlRequest error:error];
                                                                         }
                                                                     }
                                                                     if (error) {
                                                                         [self envokeCompletion:completion withError:error request:requestConvertable];
                                                                         return;
                                                                     }
                                                                     if (token.isCanceled) {
                                                                         NSError * error = [NSError errorWithDomain:sNetworkErrorDomain
                                                                                                               code:sNetworkErrorCanceled
                                                                                                           userInfo:nil];
                                                                         [self envokeCompletion:completion withError:error request:requestConvertable];
                                                                         return;
                                                                     }
                                                                     if (urlRequest == nil) {
                                                                         NSError * error = [NSError errorWithDomain:sNetworkErrorDomain
                                                                                                               code:sNetworkErrorFailToAdaptURLRequest
                                                                                                           userInfo:nil];
                                                                         [self envokeCompletion:completion withError:error request:requestConvertable];
                                                                         return;
                                                                     }
                                                                     if ([requestConvertable respondsToSelector:@selector(stubData)]) {//走假数据模式
                                                                         if ([requestConvertable stubData] != nil) {
                                                                             [self envokeSubWithrequestConvertable:requestConvertable
                                                                                                        urlRequest:urlRequest
                                                                                                        completion:completion];
                                                                             return;
                                                                         }
                                                                     }
                                                                     //重复网络请求检查
                                                                     if(self.trackRepeatRequest){
                                                                         [self.lock lock];
                                                                         NSString * requestID = urlRequest.s_unqiueIdentifier;
                                                                         NSArray * callBacks = [self.callbackMap objectForKey:requestID];
                                                                         NSMutableArray * updatedCallbacks;
                                                                         if (callBacks == nil) {
                                                                             updatedCallbacks = [NSMutableArray new];
                                                                         }else{
                                                                             updatedCallbacks = [[NSMutableArray alloc] initWithArray:callBacks];
                                                                         }
                                                                         if (completion) {
                                                                             [updatedCallbacks addObject:completion];
                                                                         }
                                                                         NSArray * array = [[NSArray alloc] initWithArray:updatedCallbacks];
                                                                         [self.callbackMap setObject:array forKey:requestID];
                                                                         [self.lock unlock];
                                                                         if (array.count > 1) {//同时存在几个一样的请求
                                                                             return;
                                                                         }
                                                                     }
                                                                     if ([requestConvertable respondsToSelector:@selector(durationForReturnCache)]) {
                                                                         NSTimeInterval duration = [requestConvertable durationForReturnCache];
                                                                         sNetworkCacheItem * item = [sNetworkCache cachedDataForRequest:urlRequest expire:duration];
                                                                         if (item) {//有缓存数据
                                                                             [self envokeCacheCallBackWithrequestConvertable:requestConvertable
                                                                                                           urlRequest:urlRequest
                                                                                                           cachedItem:item
                                                                                                           completion:completion];
                                                                             return;
                                                                         }
                                                                     }
                                                                     NSInteger retryTimes = [requestConvertable respondsToSelector:@selector(retryTimes)] ? [requestConvertable retryTimes] - 1: 0;
                                                                     [self startTaskWithRequestConvertable:requestConvertable
                                                                                                urlRequest:urlRequest
                                                                                                     token:token
                                                                                              toRetryTimes:retryTimes
                                                                                                  progress:progress
                                                                                                completion:completion];
                                                                 }];
                                        }];
    return token;
    
}

- (void)envokeCompletion:(void(^)(sNetworkResponse * response))completion withError:(NSError *)error request:(id<sRequestConvertable>) requestConvertable{
    sNetworkResponse * response = [[sNetworkResponse alloc] initWithRequest:requestConvertable urlResponse:nil responseData:nil error:error];
    sNetworkResponse * adaptedResponse = [self adaptedResponseWithOriginal:response requestConvertable:requestConvertable];
    BEGIN_ASYNC_MAIN_QUEUE
    if (completion) {
        completion(adaptedResponse);
    }
    END_ASYNC_MAIN_QUEU
}

- (void)envokeCacheCallBackWithrequestConvertable:(id<sRequestConvertable>)requestConvertable
                                       urlRequest:(NSURLRequest *)urlRequest
                                       cachedItem:(sNetworkCacheItem *)item
                                       completion:(void(^)(sNetworkResponse *  response))completion{
    BEGIN_ASYNC_MANAGER_QUEUE
    sNetworkResponse * response = [[sNetworkResponse alloc] initWithRequest:requestConvertable
                                                                  urlResponse:item.httpResponse
                                                                 responseData:item.data
                                                                        error:nil
                                                                       source:sNetworkResponseSourceLocalCache];
    if(self.trackRepeatRequest){
        [self.lock lock];
        NSString * requestID = urlRequest.s_unqiueIdentifier;
        NSArray * callBacks = [self.callbackMap objectForKey:requestID];
        for (sNetworkResposeComplete callback in callBacks) {
            [self envokeCallBack:callback withResponse:response requestConvertable:requestConvertable];
        }
        [self.callbackMap removeObjectForKey:requestID];
        [self.lock unlock];
    }else{
        [self envokeCallBack:completion withResponse:response requestConvertable:requestConvertable];
    }
    END_ASYNC_MANAGER_QUEU
}
- (void)envokeSubWithrequestConvertable:(id<sRequestConvertable>)requestConvertable
                      urlRequest:(NSURLRequest *)urlRequest
                      completion:(void(^)(sNetworkResponse *  response))completion{
    BEGIN_ASYNC_MANAGER_QUEUE
    sNetworkSub * stub = [requestConvertable stubData];
    sNetworkResponse * response;
    if (stub.sampleData) {
        response = [[sNetworkResponse alloc] initStubResponseWithRequest:requestConvertable
                                                                     data:stub];
        dispatch_after(DISPATCH_TIME_NOW + stub.delay, self.queue, ^{
            if(self.trackRepeatRequest){
                [self.lock lock];
                NSString * requestID = urlRequest.s_unqiueIdentifier;
                NSArray * callBacks = [self.callbackMap objectForKey:requestID];
                for (sNetworkResposeComplete  callback in callBacks) {
                    [self envokeCallBack:callback withResponse:response requestConvertable:requestConvertable];
                }
                [self.callbackMap removeObjectForKey:requestID];
                [self.lock unlock];
            }else{
                [self envokeCallBack:completion withResponse:response requestConvertable:requestConvertable];
            }
        });
    }
    END_ASYNC_MANAGER_QUEU
}

//适配Resoonse
- (sNetworkResponse *)adaptedResponseWithOriginal:(sNetworkResponse *)response requestConvertable:(id<sRequestConvertable>)requestConvertable{
    for (id<sNetworkPlugin> plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(willAdaptResponse:)]) {
            [plugin willAdaptResponse:response];
        }
    }
    sNetworkResponse * adaptedResponse;
    if ([requestConvertable respondsToSelector:@selector(adaptResponse:)]) {
        adaptedResponse = [requestConvertable adaptResponse:response];
        NSAssert(adaptedResponse != nil, @"You can not return a empty response here");
        NSString * reason = nil;
        NSError * error;
        if (adaptedResponse.responseObject == nil && !response.error) {
            reason =  @"We got empty responseObject";
        }
        if ([requestConvertable respondsToSelector:@selector(classTypeForResponse)]) {
            Class rightClass = [requestConvertable classTypeForResponse];
            if (![[adaptedResponse responseObject] isKindOfClass:rightClass]) {//类型不对
                reason = [NSString stringWithFormat: @"The reqeust claims that responseObject class is %@, but we got %@",rightClass,[adaptedResponse.responseObject class]];
            }
        }
        if (reason != nil) {
            error = [NSError errorWithDomain:sNetworkErrorDomain
                                        code:sNetworkErrorFailToAdaptedResponse
                                    userInfo:@{@"reason":reason}];
        }
        if (error) {
            adaptedResponse = [[sNetworkResponse alloc] initWithResponse:response udpatedError:error];
            adaptedResponse = [[sNetworkResponse alloc] initWithResponse:adaptedResponse adpatedObject:nil];
        }
    }else{
        adaptedResponse = response;
    }
    for (id<sNetworkPlugin> plugin in self.plugins) {
        if ([plugin respondsToSelector:@selector(didAdaptedResponse:)]) {
            [plugin didAdaptedResponse:response];
        }
    }
    return adaptedResponse;
}

- (void)envokeCallBack:(sNetworkResposeComplete)callback
          withResponse:(sNetworkResponse *)response
           requestConvertable:(id<sRequestConvertable>)requestConvertable{
    sNetworkResponse * adaptedResponse = [self adaptedResponseWithOriginal:response requestConvertable:requestConvertable];
    BEGIN_ASYNC_MAIN_QUEUE
    callback(adaptedResponse);
    END_ASYNC_MAIN_QUEU
}

- (void)startTaskWithRequestConvertable:(id<sRequestConvertable>)requestConvertable
                             urlRequest:(NSURLRequest *)urlRequest
                                  token:(sRequstToken *)token
                           toRetryTimes:(NSInteger)retryTimes
                               progress:(sNetworkResposeProgress)progress
                             completion:(void(^)(sNetworkResponse *  response))completion{
    sRequestType * requestType = [sRequestType data];
    if ([requestConvertable respondsToSelector:@selector(requestType)]) {
        requestType = [requestConvertable requestType];
    }
    sAFDataTaskCompletionBlock dataCompletion = ^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        BEGIN_ASYNC_MANAGER_QUEUE
        for (id<sNetworkPlugin> plugin in self.plugins) {
            if ([plugin respondsToSelector:@selector(didReceiveResponse:responseObject:filePath:error:)]) {
                [plugin didReceiveResponse:response responseObject:responseObject filePath:nil error:error];
            }
        }
        if (token.isCanceled) {
            NSError * error = [NSError errorWithDomain:sNetworkErrorDomain
                                                  code:sNetworkErrorCanceled
                                              userInfo:nil];
            [self envokeCompletion:completion withError:error request:requestConvertable];
            return;
        }
        if (retryTimes > 0 && error) {
            [self startTaskWithRequestConvertable:requestConvertable
                                       urlRequest:urlRequest
                                            token:token
                                     toRetryTimes:(retryTimes - 1)
                                         progress:progress
                                       completion:completion];
            return;
        }
        //保存数据
        if ([requestConvertable respondsToSelector:@selector(durationForReturnCache)] && !error) {
            NSTimeInterval duration = [requestConvertable durationForReturnCache];
            if (duration > 0) {
                [sNetworkCache saveCache:responseObject
                               forRequset:urlRequest
                             httpResponse:response
                                   expire:duration];
            }
        }
        sNetworkResponse * networkResponse = [[sNetworkResponse alloc] initWithRequest:requestConvertable
                                                                             urlResponse:response
                                                                            responseData:responseObject
                                                                                   error:error];
        if(self.trackRepeatRequest){
            [self.lock lock];
            NSString * requestID = urlRequest.s_unqiueIdentifier;
            NSArray * callBacks = [self.callbackMap objectForKey:requestID];
            for (sNetworkResposeComplete callback in callBacks) {
                [self envokeCallBack:callback withResponse:networkResponse requestConvertable:requestConvertable];
            }
            [self.callbackMap removeObjectForKey:requestID];
            [self.lock unlock];
        }else{
            [self envokeCallBack:completion withResponse:networkResponse requestConvertable:requestConvertable];
        }
        END_ASYNC_MANAGER_QUEU
    };
    if ([requestType isKindOfClass:[sRequestTypeDownlaod class]]) {//下载任务
        sRequestTypeDownlaod * download = (sRequestTypeDownlaod *)requestType;
        
        sAFDownloadTaskCompletionBlock downloadCompletion = ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            BEGIN_ASYNC_MANAGER_QUEUE
            for (id<sNetworkPlugin> plugin in self.plugins) {
                if ([plugin respondsToSelector:@selector(didReceiveResponse:responseObject:filePath:error:)]) {
                    [plugin didReceiveResponse:response responseObject:nil filePath:filePath error:error];
                }
            }
            if (token.isCanceled) {
                NSError * error = [NSError errorWithDomain:sNetworkErrorDomain
                                                      code:sNetworkErrorCanceled
                                                  userInfo:nil];
                [self envokeCompletion:completion withError:error request:requestConvertable];
                return;
            }
            if (retryTimes > 0 && error) {
                [self startTaskWithRequestConvertable:requestConvertable
                                           urlRequest:urlRequest
                                                token:token
                                         toRetryTimes:(retryTimes - 1)
                                             progress:progress
                                           completion:completion];
                return;
            }
            sNetworkResponse * networkResponse = [[sNetworkResponse alloc] initWithRequest:requestConvertable
                                                                                 urlResponse:response
                                                                                    filePath:filePath
                                                                                       error:error];
            if(self.trackRepeatRequest){
                [self.lock lock];
                NSString * requestID = urlRequest.s_unqiueIdentifier;
                NSArray * callBacks = [self.callbackMap objectForKey:requestID];
                for (sNetworkResposeComplete callback in callBacks) {
                    [self envokeCallBack:callback withResponse:networkResponse requestConvertable:requestConvertable];
                }
                [self.callbackMap removeObjectForKey:requestID];
                [self.lock unlock];
            }else{
                [self envokeCallBack:completion withResponse:networkResponse requestConvertable:requestConvertable];
            }
            END_ASYNC_MANAGER_QUEU
        };
        NSURLSessionDownloadTask * task;
        if (!download.resumeData) {
            task = [self.afSessionManager downloadTaskWithRequest:urlRequest progress:^(NSProgress * _Nonnull downloadProgress) {
                *progress = downloadProgress;
            } destination:download.destionation completionHandler:downloadCompletion];

        }else{
            task = [self.afSessionManager downloadTaskWithResumeData:download.resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
                *progress = downloadProgress;
            } destination:download.destionation completionHandler:downloadCompletion];
        }
        token.task = task;
        [task resume];
    }else if ([requestConvertable isKindOfClass:[sRequestTypeUpload class]]) {//上传任务
        sRequestTypeUpload * upload = (sRequestTypeUpload *)requestConvertable.requestType;
        NSURLSessionUploadTask * task;
        if (upload.data) {
            task = [self.afSessionManager uploadTaskWithRequest:urlRequest fromData:upload.data progress:^(NSProgress * _Nonnull uploadProgress) {
                *progress = uploadProgress;
            } completionHandler:dataCompletion];
        }else if(!upload.isMultiPartFormData){
            task = [self.afSessionManager uploadTaskWithRequest:urlRequest fromFile:upload.fileURL progress:^(NSProgress * _Nonnull uploadProgress) {
                *progress = uploadProgress;
            } completionHandler:dataCompletion];
        }else{
            task = [self.afSessionManager uploadTaskWithStreamedRequest:urlRequest progress:^(NSProgress * _Nonnull uploadProgress) {
                *progress = uploadProgress;
            } completionHandler:dataCompletion];
        }

        token.task = task;
        [task resume];
    }else{

        NSURLSessionDataTask * task = [self.afSessionManager dataTaskWithRequest:urlRequest uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
            
        } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
            
        } completionHandler:dataCompletion];
        token.task = task;
        [task resume];
    }

}
@end

