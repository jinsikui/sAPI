//
//  sNetworkJSONValider.m
//  sNetwork
//
//  Created by jinsikui on 2021/8/17.
//  Copyright © 2021年 jinsikui. All rights reserved.
//


#import "sNetworkResponseValider.h"

NSString * const sNetworkResponseValiderErrorDomain = @"com.snetwork.response.valider";

@interface sJSONSchemaValider()

@property (strong, nonatomic) NSArray * schemaArray;

@property (strong, nonatomic) NSDictionary * schemaDictionary;
@end

@implementation sJSONSchemaValider

+ (instancetype)arrayValiderWithScheme:(NSArray *)scheme{
    sJSONSchemaValider * valider = [[sJSONSchemaValider alloc] init];
    valider.schemaArray = scheme;
    return valider;
}

+ (instancetype)objectValiderWithScheme:(NSDictionary *)scheme{
    sJSONSchemaValider * valider = [[sJSONSchemaValider alloc] init];
    valider.schemaDictionary = scheme;
    return valider;
}

- (BOOL)validateJSON:(id)json withValidator:(id)jsonValidator error:(NSError **)error{
    if ([json isKindOfClass:[NSDictionary class]] &&
        [jsonValidator isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = json;
        NSDictionary * validator = jsonValidator;
        BOOL result = YES;
        NSEnumerator * enumerator = [validator keyEnumerator];
        NSString * key;
        while ((key = [enumerator nextObject]) != nil) {
            id value = dict[key];
            id format = validator[key];
            if ([value isKindOfClass:[NSDictionary class]]
                || [value isKindOfClass:[NSArray class]]) {
                result = [self validateJSON:value withValidator:format error:error];
                if (!result) {
                    break;
                }
            } else if (value != nil){
                if ([value isKindOfClass:format] == NO &&
                    [value isKindOfClass:[NSNull class]] == NO) {
                    NSString * reason = [NSString stringWithFormat:@"Class in scheme is %@, but we got class %@ from response.",format, [value class]];
                    NSDictionary * userInfo = @{@"InvalidReason":reason,@"InvalidData":value};
                    NSError * validerError = [NSError errorWithDomain:sNetworkResponseValiderErrorDomain
                                                          code:-1
                                                      userInfo:userInfo];
                    *error = validerError;
                    result = NO;
                    break;
                }
            }
        }
        return result;
    } else if ([json isKindOfClass:[NSArray class]] &&
               [jsonValidator isKindOfClass:[NSArray class]]) {
        NSArray * validatorArray = (NSArray *)jsonValidator;
        if (validatorArray.count > 0) {
            NSArray * array = json;
            NSDictionary * validator = jsonValidator[0];
            for (id item in array) {
                BOOL result = [self validateJSON:item withValidator:validator error:error];
                if (!result) {
                    return NO;
                }
            }
        }
        return YES;
    } else if ([json isKindOfClass:jsonValidator]) {
        return YES;
    } else {
        return NO;
    }
}



- (BOOL)validResponse:(id)json error:(NSError **)error{
    if (self.schemaDictionary && [json isKindOfClass:[NSDictionary class]]) {//按照字典的方式验证
        return [self validateJSON:json withValidator:self.schemaDictionary error: error];
    }else if(self.schemaArray && [json isKindOfClass:[NSArray class]]){
        return [self validateJSON:json withValidator:self.schemaArray error:error];
    }
    return NO;
}

@end
