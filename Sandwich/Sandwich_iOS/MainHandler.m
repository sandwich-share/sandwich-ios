//
//  MainHandler.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/25/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "MainHandler.h"
#import "Bootstrapper.h"
#import "DBManager.h"

@implementation MainHandler
static NSArray* PeerList;
static NSString* IP;
static NSUserDefaults* userPrefs;
static SearchManager* searchMan;

+ (void) setPeerList:(NSArray*)peerlist {
    PeerList = peerlist;
    DBManager* dbMan = [[DBManager alloc]init];
    [dbMan writePeerListToDatabase:peerlist];
}

+ (NSArray*) getPeerList {
    return PeerList;
}

+ (void) setInitialNode:(NSString *)ip {
    //TODO: should resolve hostname and only store IPs
    IP = ip;
}

+ (NSString*) getInitialNode {
    return [userPrefs stringForKey:@"IP"];
}

+ (SearchManager *)getSearchManager {
    if (searchMan == NULL) {
        searchMan = [[SearchManager alloc] init];
    }
    return searchMan;
}

- (void) main {
    userPrefs =  [NSUserDefaults standardUserDefaults];
    NSLog(@"Main Handler is getting strapped");
    Bootstrapper* bs = [[Bootstrapper alloc] init];
    [bs strapMeToAPeer];
    [bs downloadIndexes];
}

@end
