//
//  Exception.m
//  DocumentStore
//
//  Created by Mathijs Kadijk on 19-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

#import "Exception.h"

@implementation Exception

+ (NSException * _Nullable)raisedInBlock:(__attribute__((noescape)) void(^_Nonnull)(void))block {
  @try {
    block();
    return nil;
  }
  @catch (NSException *exception) {
    return exception;
  }
}

@end
