//
//  MainHandler.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/25/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchManager.h"
#import "DBManager.h"
#import "ConnectionManager.h"
#import "BootstrapManager.h"

@interface MainHandler : NSOperation
+ (void) setPeerList:(NSArray*)peerList;
+ (NSArray*) getPeerList;
+ (void) removeFromPeerList:(Peer*)peer;
+ (void) setInitialNode:(NSString*)ip;
+ (NSString*) getInitialNode;
+ (SearchManager*) getSearchManager;
+ (DBManager*) getDBManager;
+ (ConnectionManager*) getConnectionManager;
+ (BootstrapManager*) getBootstrapManager;
+ (NSOperationQueue*) getThreadPool;
@end
