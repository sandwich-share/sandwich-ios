//
//  ConnectionManager.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/25/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "ConnectionManager.h"
#import "Peer.h"
#import <CommonCrypto/CommonDigest.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

@implementation ConnectionManager

- (NSArray*) getPeerList:(Peer*)peer {
    NSString* ip = [peer getIp];
    unsigned short port = [ConnectionManager portForIP:ip];
    NSString* urlString = [NSString stringWithFormat:@"http://%@:%u/peerlist", ip, port];
    NSURL* url = [NSURL URLWithString:urlString];

    NSData* peerlist = [NSData dataWithContentsOfURL:url];
    
    if (peerlist == nil) {
        NSLog(@"Error getting peerlist for: %@", ip);
        return NULL;
    } else {
        NSArray* json = [NSJSONSerialization JSONObjectWithData:peerlist options:kNilOptions error:nil];
        NSMutableArray* listOfPeers = [[NSMutableArray alloc] initWithCapacity:json.count];
        
        for (int i = 0; i < json.count; i++) {
            NSString* ip = [json[i] objectForKey:@"IP"];
            NSNumber* indexHash = [json[i] objectForKey:@"IndexHash"];
            NSString* lastSeen = [json[i] objectForKey:@"LastSeen"];
            Peer* peer = [[Peer alloc] initWithPeerInfo:ip indexhash:indexHash lastSeen:lastSeen];
            [listOfPeers addObject:peer];
        }
        
        return listOfPeers;
    }
}


+ (unsigned short) portForIP: (NSString*)ip {
	in_addr_t address = inet_addr([ip UTF8String]);
	unsigned char addr[16], digest[16];
	unsigned short port;
    
	memset(addr, 0, 16);
	addr[10] = 0xFF;
	addr[11] = 0xFF;
	memcpy(&addr[12], &address, sizeof(address));
	
	CC_MD5( addr, 16, digest ); // This is the md5 call
	
	port = (digest[0] + digest[3]) << 8;
	port += (digest[1] + digest[2]);
	NSLog(@"%@ -> %d", ip, port);
	return port;
}


@end
