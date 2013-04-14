//
//  PerformSearch.h
//  Sandwich
//
//  Created by Diego Waxemberg on 4/12/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peer.h"
#import "Peerlist.h"
#import <sqlite3.h>
#import "ViewController.h"

@interface PerformSearch : NSOperation
@property Peer* peer;
@property sqlite3* peerDB;
@property ViewController* tableview;
@property NSString* searchParam;

- (PerformSearch*) initWithPeer: (sqlite3*)indexDB peer:(Peer*)peer searchParameter:(NSString*)searchParam tableview:(ViewController*)tableview;

@end
