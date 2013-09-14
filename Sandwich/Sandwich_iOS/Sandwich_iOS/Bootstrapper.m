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
#import <stdlib.h>

@implementation Bootstrapper {
    ConnectionManager* conMan;
}

- (void) strapMeToAPeer {
    DBManager* dbMan = [MainHandler getDBManager];
    NSMutableArray* peers = [dbMan getPeersForBootstrap];

    if (peers == NULL) {
        NSLog(@"Fuck");
        return;
    } else if (peers.count == 0) {
        NSLog(@"Using initial node");
        //TODO: Use the user specified initial node!
        Peer* p = [[Peer alloc]initWithPeerInfo:@"107.21.226.221" indexhash:NULL lastSeen:NULL];
        NSArray* initialNodePeers = [conMan getPeerList:p];
        if (initialNodePeers != NULL) {
            [peers addObjectsFromArray:initialNodePeers];
        }
    }
    if (peers != NULL && peers.count > 0) {
        NSLog(@"Got %d peers", peers.count);
        [MainHandler setPeerList:peers];
    } else {
        NSLog(@"ERROR! Could not bootstrap to a peer");
    }
}

- (void) main {
    NSLog(@"Bootstrapper: checking random peer");
    NSArray* currentPeerList = [MainHandler getPeerList];
    int r = arc4random_uniform(currentPeerList.count);
    NSArray* peerlist = [conMan getPeerList:[currentPeerList objectAtIndex:r]];
    if (peerlist != NULL) {
        DBManager* dbMan = [MainHandler getDBManager];
        for (Peer* p in peerlist) {
            Peer* myPeer = NULL;
            for (Peer* curPeer in currentPeerList) {
                if ([[p getIp]isEqualToString:[curPeer getIp]]) {
                    myPeer = curPeer;
                    break;
                }
            }
            NSString* myLastSeenStr = [myPeer getLastSeen];
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"];
            NSDate* myLastSeen = [dateFormatter dateFromString:myLastSeenStr];
            NSDate* theirLastSeen = [dateFormatter dateFromString:[p getLastSeen]];
            if ([myLastSeen earlierDate:theirLastSeen] == theirLastSeen) {
                NSLog(@"My index for peer: %@ is out of date, getting new one", [p getIp]);
                NSLog(@"My date: %@ their date: %@", myLastSeen, theirLastSeen);
                [dbMan writeIndexToDatabase:[conMan getIndex:p]peer:p];
            }
        }
    }
}

    


- (void)downloadIndexes {
    NSOperationQueue* indexQueue = [MainHandler getThreadPool];
    NSArray* peerlist = [MainHandler getPeerList];
    
    for (Peer* p in peerlist) {
        NSLog(@"Starting index thread for: %@", [p getIp]);
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
