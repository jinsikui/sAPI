//
//  NSURLRequest+sNetwork.h
//  sNetwork
//
//  Created by jinsikui on 2021/8/16.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (sNetwork)

/**
 URLRequest的唯一标识符
 */
- (NSString *)s_unqiueIdentifier;

@end
