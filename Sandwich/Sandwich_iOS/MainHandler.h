//
//  MainHandler.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/25/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchManager.h"

@interface MainHandler : NSOperation
+ (void)setPeerList:(NSArray*)peerList;
+ (NSArray*)getPeerList;
+ (void)setInitialNode:(NSString*)ip;
+ (NSString*)getInitialNode;
+ (SearchManager*) getSearchManager;
@end
