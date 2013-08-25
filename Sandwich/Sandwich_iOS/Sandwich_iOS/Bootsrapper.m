//
//  Bootsrapper.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/25/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "Bootsrapper.h"
#import "ConnectionManager.h"
#import "DBManager.h"

@implementation Bootsrapper {
    ConnectionManager* conMan;
}

- (void) main {
    DBManager* dbMan = [[DBManager alloc] init];
    NSArray* peers = [dbMan getPeersForBootstrap];
    
    if (peers == NULL) {
        NSLog(@"Shit bro we ain't got no peers!");
        //try to connect to the peer in settings and if that fails do something else
    } else {
        for (int i = 0; i < peers.count; i++) {
            NSArray* peerlist = [conMan getPeerList:[peers objectAtIndex:i]];
            if (peerlist != NULL) {
                //set some static array to that peerlist (or just do the rest of the setup in this class)
                break;
            }
        }
    }
}


- (Bootsrapper*) init {
    self = [super init];
    conMan = [[ConnectionManager alloc] init];
    return self;
}

@end
