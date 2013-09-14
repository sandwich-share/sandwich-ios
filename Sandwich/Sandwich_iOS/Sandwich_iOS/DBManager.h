//
//  DBManager.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/24/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Peer.h"

@interface DBManager : NSObject
- (NSMutableArray*) getPeersForBootstrap;
- (void) writeIndexToDatabase:(NSArray*)index peer:(Peer*)peer;
- (void) writePeerListToDatabase:(NSArray*)peerlist;
- (void) updatePeerlist;
- (NSArray*) searchInPeer:(Peer*)peer searchParam:(NSString*)param;

@end
