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

- (BOOL) strapMeToAPeer {
    DBManager* dbMan = [MainHandler getDBManager];
    NSArray* peers = [dbMan getPeersForBootstrap];

    if (peers.count > 0) {
        NSLog(@"Got %d peers", peers.count);
        for (Peer* p in peers) {
            NSArray* peerlist = [conMan getPeerList:p];
            if (peerlist.count > 0) {
                peers = peerlist;
                break;
            }
        }
        if (peers.count > 0) {
            [MainHandler setPeerList:peers];
            return TRUE;
        }
    } else {
        NSLog(@"No peers in DB, strapping to initial node");
        NSArray* peerlist = [conMan getPeerList:[MainHandler getInitialNode]];
        if (peerlist.count > 0) {
            [MainHandler setPeerList:peerlist];
        } else {
            NSLog(@"Could not bootstrap!");
            return FALSE;
        }

    }
    return FALSE;
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
