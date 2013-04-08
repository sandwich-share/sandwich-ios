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

@interface IndexDownloadThread : NSThread
@property Peer* peer;
@property struct sqlite3* indexDB;

- (unsigned short) portForIP: (NSString*) ip;
- (IndexDownloadThread*) initWithPeer: (Peer*)peer;
@end
