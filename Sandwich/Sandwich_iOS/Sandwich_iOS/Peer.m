//
//  Peer.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/24/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "Peer.h"

@implementation Peer {
    NSString* Ip;
    NSNumber* IndexHash;
    NSString* LastSeen;
}

- (NSString*) getIp {
    return self->Ip;
}

- (NSNumber*) getIndexHash {
    return self->IndexHash;
}

- (NSString*) getLastSeen {
    return self->LastSeen;
}

- (Peer*) initWithPeerInfo: (NSString*)ip indexhash:(NSNumber*)indexHash lastSeen:(NSString*)lastSeen{
    self = [super init];
    self->Ip = ip;
    self->IndexHash = indexHash;
    self->LastSeen = lastSeen;
    return self;
}
@end
