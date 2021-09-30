//
//  sNetworkJSONValider.h
//  sNetwork
//
//  Created by jinsikui on 2021/8/17.
//  Copyright © 2021年 jinsikui. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const sNetworkResponseValiderErrorDomain;

@protocol sNetworkResponseValider<NSObject>

- (BOOL)validResponse:(id)json error:(NSError **)error;


@end

/**
 对JSON的Schema进行验证
 */
@interface sJSONSchemaValider : NSObject <sNetworkResponseValider>

/**
 对JSON Array进行验证，

 @param scheme JSON的Scheme
 */
+ (instancetype)arrayValiderWithScheme:(NSArray *)scheme;

/**
 对JSON Object进行验证，
 
 @param scheme JSON的Scheme
 */
+ (instancetype)objectValiderWithScheme:(NSDictionary *)scheme;

@end
