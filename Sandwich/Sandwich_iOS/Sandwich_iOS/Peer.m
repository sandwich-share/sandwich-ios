//
//  Peer.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/24/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "Peer.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@implementation Peer {
    NSString* Ip;
    NSNumber* IndexHash;
    NSString* LastSeen;
}

- (NSString*) getIp {
    return self->Ip;
}

- (uint32_t) get32BitIp {
    const char* ipChar = [Ip UTF8String];
    return inet_addr(ipChar);
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
