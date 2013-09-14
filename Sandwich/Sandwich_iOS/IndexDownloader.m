//
//  IndexDownloader.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/26/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "IndexDownloader.h"
#import "ConnectionManager.h"
#import "MainHandler.h"
#import "DBManager.h"

@implementation IndexDownloader {
    Peer* MyPeer;
}

- (void)main {
    NSLog(@"Downloading index for: %@", [MyPeer getIp]);
    ConnectionManager* conMan = [[ConnectionManager alloc] init];
    NSArray* index = [conMan getIndex:MyPeer];
    DBManager* dbMan = [MainHandler getDBManager];
    NSLog(@"writing index with %d entries from peer %@ to database", index.count, [MyPeer getIp]);
    [dbMan writeIndexToDatabase:index peer:MyPeer];
    NSLog(@"updating peerlist");
    [dbMan updatePeerlist];
}


- (id)initWithPeer:(Peer *)peer {
    self = [super init];
    MyPeer = peer;
    return self;
}

@end
