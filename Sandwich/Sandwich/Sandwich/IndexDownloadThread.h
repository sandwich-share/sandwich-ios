//
//  IndexDownloadThread.h
//  Sandwich
//
//  Created by Diego Waxemberg on 4/6/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peer.h"
#import <sqlite3.h>

@interface IndexDownloadThread : NSOperation
@property Peer* peer;
@property struct sqlite3* indexDB;
@property NSDictionary* index;

- (unsigned short) portForIP: (NSString*) ip;
+ (unsigned short) portForPeer: (NSString*) ip;
- (BOOL) needToUpdate;
- (NSDictionary*) getIndex;
- (void) setFinished;
//- (BOOL) insertIndex;
- (IndexDownloadThread*) initWithPeer: (Peer*)peer;





@end
