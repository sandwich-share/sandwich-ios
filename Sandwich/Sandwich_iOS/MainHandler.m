//
//  MainHandler.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/25/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "MainHandler.h"

@implementation MainHandler
static NSArray* PeerList;
static NSString* IP;
static NSUserDefaults* userPrefs;
static SearchManager* searchMan;
static DBManager* dbMan;
static ConnectionManager* conMan;
static BootstrapManager* bootMan;
static MediaManager* mediaMan;
static NSOperationQueue* threadPool;

+ (void) setPeerList:(NSArray*)peerlist {
    NSLog(@"Setting peerlist with %d peers", peerlist.count);
    PeerList = peerlist;
    DBManager* dbMan = [[DBManager alloc]init];
    [dbMan writePeerListToDatabase:peerlist];
}

+ (NSArray*) getPeerList {
    return PeerList;
}

+ (void) removeFromPeerList:(Peer*)peer {
    NSMutableArray* newPeerList = [[NSMutableArray alloc]  initWithArray:PeerList];
    [newPeerList removeObject:peer];
    [MainHandler setPeerList:newPeerList];
}

+ (void) setInitialNode:(NSString *)ip {
    //TODO: should resolve hostname and only store IPs
    IP = ip;
}

+ (Peer*) getInitialNode {
    //TODO: Make this work
    //return [userPrefs stringForKey:@"IP"];
    return [[Peer alloc] initWithPeerInfo:@"107.21.226.221" indexhash:NULL lastSeen:NULL];
}

+ (SearchManager *)getSearchManager {
    if (searchMan == NULL) {
        searchMan = [[SearchManager alloc] init];
    }
    return searchMan;
}

+ (DBManager *)getDBManager {
    if (dbMan == NULL) {
        dbMan = [[DBManager alloc] init];
    }
    return dbMan;
}

+ (ConnectionManager *)getConnectionManager {
    if (conMan == NULL) {
        conMan = [[ConnectionManager alloc] init];
    }
    return conMan;
}

+ (BootstrapManager*) getBootstrapManager {
    if (bootMan == NULL) {
        bootMan = [[BootstrapManager alloc] init];
    }
    return bootMan;
}

+ (NSOperationQueue*) getThreadPool {
    if (threadPool == NULL) {
        threadPool = [[NSOperationQueue alloc] init];
        [threadPool setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    }
    return threadPool;
}

+ (MediaManager *)getMediaManager {
    if (mediaMan == NULL) {
        mediaMan = [[MediaManager alloc] init];
    }
    return mediaMan;
}

- (void) main {
    //TODO: Actually use these prefs
    userPrefs =  [NSUserDefaults standardUserDefaults];
    
    NSLog(@"Main Handler is getting strapped");
    BootstrapManager* bMan = [MainHandler getBootstrapManager];
    [bMan performInitialStrap];
    if (PeerList.count > 0) {
        [bMan startUpBootstrapTimer];
    }
}

@end
