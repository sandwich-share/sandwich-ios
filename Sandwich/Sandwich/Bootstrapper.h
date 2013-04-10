//
//  Bootstrapper.h
//  Sandwich
//
//  Created by Diego Waxemberg on 4/6/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Peer.h"

@interface Bootstrapper : NSOperation
@property NSMutableSet* peerList;

- (void) downloadIndexes: (Peer*) peer;
- (Bootstrapper*) initWithPeerlist: (NSMutableSet*)peerList;
- (void) setFinished;

@end
