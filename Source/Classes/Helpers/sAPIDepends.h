//
//  sAPIDepends.h
//  sAPI
//
//  Created by jinsikui on 2021/9/6.
//

#ifndef sAPIDepends_h
#define sAPIDepends_h

#import "sAPIHelper.h"

#if __has_include(<FBLPromises/FBLPromises.h>)
#import <FBLPromises/FBLPromises.h>
#else
#import "FBLPromises.h"
#endif
#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif
#import "sNetwork.h"


#endif /* sAPIDepends_h */
