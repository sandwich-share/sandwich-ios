//
//  Bootsrapper.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/25/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "Bootstrapper.h"
#import "ConnectionManager.h"
#import "DBManager.h"
#import "MainHandler.h"
#import "IndexDownloader.h"

@implementation Bootstrapper {
    ConnectionManager* conMan;
}

- (void) strapMeToAPeer {
    DBManager* dbMan = [[DBManager alloc] init];
    NSMutableArray* peers = [dbMan getPeersForBootstrap];

    if (peers == NULL) {
        NSLog(@"Fuck");
        return;
    } else if (peers.count == 0) {
        NSLog(@"Using initial node");
        Peer* p = [[Peer alloc]initWithPeerInfo:@"129.22.47.134" indexhash:NULL lastSeen:NULL];
        [peers addObject: p];
    } else {
        NSLog(@"Got some peers, searching for a peerlist");
    }

    for (int i = 0; i < peers.count; i++) {
        NSArray* peerlist = [conMan getPeerList:[peers objectAtIndex:i]];
        if (peerlist != NULL) {
            [MainHandler setPeerList:peerlist];
            NSLog(@"Setting peerlist with %d peers.", peerlist.count);
            break;
        }
    }
}

- (void)downloadIndexes {
    NSOperationQueue* indexQueue = [[NSOperationQueue alloc]init];
    [indexQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    NSArray* peerlist = [MainHandler getPeerList];
    
    for (Peer* p in peerlist) {
        IndexDownloader* dler = [[IndexDownloader alloc]initWithPeer:p];
        [indexQueue addOperation:dler];
    }
}

- (Bootstrapper*) init {
    self = [super init];
    conMan = [[ConnectionManager alloc] init];
    return self;
}

@end
