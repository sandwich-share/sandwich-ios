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
    ConnectionManager* conMan = [[ConnectionManager alloc] init];
    NSArray* index = [conMan getIndex:MyPeer];
    DBManager* dbMan = [[DBManager alloc]init];
    [dbMan writeIndexToDatabase:index peer:MyPeer];
}


- (id)initWithPeer:(Peer *)peer {
    self = [super init];
    MyPeer = peer;
    return self;
}

@end
