//
//  sAPIHelper.m
//  sAPI
//
//  Created by jinsikui on 2021/9/6.
//

#import "sAPIHelper.h"

@implementation sAPIHelper

+ (NSString*)urlEncode:(NSString*)input{
    NSMutableCharacterSet *set = [NSMutableCharacterSet whitespaceCharacterSet];
    [set addCharactersInString:@"!*'();:@&=+$/?%#[]"];
    NSString *outputStr = [input stringByAddingPercentEncodingWithAllowedCharacters:set.invertedSet];
    return outputStr;
}

+ (NSString*)mergeToInput:(NSString*)input queryParams:(NSDictionary*)params{
    if (params.count == 0 || !input) {
        return input;
    }
    NSURLComponents * components = [NSURLComponents componentsWithString:input];
    NSMutableArray<NSURLQueryItem*> * queryItems = [[NSMutableArray alloc] initWithArray:components.queryItems ?: @[]];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSObject * _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *value = [NSString stringWithFormat:@"%@",obj];
        key = [self urlEncode:key];
        obj = [self urlEncode:value];
        NSURLQueryItem *item = nil;
        for(NSURLQueryItem *it in queryItems) {
            if([it.name isEqualToString:key]){
                item = it;
                break;
            }
        };
        if (item) {
            [queryItems removeObject:item];
        }
        item = [NSURLQueryItem queryItemWithName:key value:value];
        [queryItems addObject:item];
    }];
    components.queryItems = queryItems;
    return components.string;
}

@end
