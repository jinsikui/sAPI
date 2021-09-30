//
//  NSURLRequest+sNetwork.m
//  sNetwork
//
//  Created by jinsikui on 2021/8/16.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import "NSURLRequest+sNetwork.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSURLRequest (sNetwork)

- (NSString *)s_unqiueIdentifier{
    NSString * path = [[self URL] absoluteString];
    NSString * bodyStr = @"";
    if (self.HTTPBody) {
        bodyStr = [[NSString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding];
    }
    NSString * identify = [path stringByAppendingString:bodyStr];
    NSString * md5 = [self sn_md5:identify];
    return md5;
}

- (NSString *)sn_md5:(NSString *)input{
    const char *cStr = [input UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
@end
