//
//  Exception.h
//  DocumentStore
//
//  Created by Mathijs Kadijk on 19-11-16.
//  Copyright © 2016 Mathijs Kadijk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Exception : NSObject

+ (NSException * _Nullable)raisedInBlock:(__attribute__((noescape)) void(^_Nonnull)(void))block;

@end
