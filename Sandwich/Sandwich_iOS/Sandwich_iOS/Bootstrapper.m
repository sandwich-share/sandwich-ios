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

@implementation Bootstrapper {
    ConnectionManager* conMan;
}

- (void) strapMeToAPeer {
    DBManager* dbMan = [[DBManager alloc] init];
    NSArray* peers = [dbMan getPeersForBootstrap];
    
    if (peers == NULL) {
        NSLog(@"Shit bro we ain't got no peers!");

    } else {
        NSLog(@"Got some peers, searching for a peerlist");
        for (int i = 0; i < peers.count; i++) {
            NSArray* peerlist = [conMan getPeerList:[peers objectAtIndex:i]];
            if (peerlist != NULL) {
                [MainHandler setPeerList:peerlist];
                NSLog(@"Setting peerlist with %d peers.", peerlist.count);
                break;
            }
        }
    }
}


- (Bootstrapper*) init {
    self = [super init];
    conMan = [[ConnectionManager alloc] init];
    return self;
}

@end
