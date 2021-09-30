//
//  sHTTPRequestType.m
//  sNetwork
//
//  Created by jinsikui on 2021/8/14.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import "sRequestType.h"

@interface sRequestTypeUpload()

@property (assign, nonatomic, readwrite) BOOL isMultiPartFormData;

@property (copy, nonatomic, readwrite)void (^constructingBodyBlock)(id <AFMultipartFormData> formData);

@property (strong, nonatomic, readwrite) NSURL * fileURL;

@property (strong, nonatomic, readwrite) NSData * data;

@end

@implementation sRequestTypeUpload

- (instancetype)initWithFileURL:(NSURL *)fileURL{
    if (self = [super init]) {
        self.fileURL = fileURL;
        self.isMultiPartFormData = NO;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data{
    if (self = [super init]) {
        self.data = data;
        self.isMultiPartFormData = NO;
    }
    return self;
}
@end

@interface sRequestTypeDownlaod()

@property (strong, nonatomic, readwrite) NSData * resumeData;

@property (strong, nonatomic, readwrite) sNetworkResponseDownlaodDestination destionation;

@end

@implementation sRequestTypeDownlaod

- (instancetype)initWithResumeData:(NSData *)data destionation:(sNetworkResponseDownlaodDestination)destionation{
    if (self = [super init]) {
        self.resumeData = data;
        self.destionation = destionation;
    }
    return self;
}

@end

@implementation sRequestType

+ (instancetype)data{
    return [[sRequestType alloc] init];
}

+ (instancetype)uploadFromData:(NSData *)data{
    return (sRequestType *)[[sRequestTypeUpload alloc] initWithData:data];
}

+ (instancetype)uploadFromFileURL:(NSURL *)fileURL{
    return (sRequestType *)[[sRequestTypeUpload alloc] initWithFileURL:fileURL];
}

+ (instancetype)downlaodWithDestination:(sNetworkResponseDownlaodDestination)destination{
    return (sRequestType *)[[sRequestTypeDownlaod alloc] initWithResumeData:nil
                                                                 destionation:destination];
}

+ (instancetype)downloadWithResumeData:(NSData *)resumeData destination:(sNetworkResponseDownlaodDestination)destination{
    return (sRequestType *)[[sRequestTypeDownlaod alloc] initWithResumeData:resumeData
                                                                 destionation:destination];
}


+ (instancetype)uploadWithMultipartFormConstructingBodyBlock:(void (^)(id<AFMultipartFormData> _Nonnull))block{
    sRequestTypeUpload * type =  [[sRequestTypeUpload alloc] init];
    type.constructingBodyBlock = block;
    type.isMultiPartFormData = YES;
    return type;
}
@end

