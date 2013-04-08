//
//  Bootstrapper.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/6/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "Bootstrapper.h"
#import "IndexDownloadThread.h"

@implementation Bootstrapper

- (void) downloadIndexes: (Peer*) peer {
    NSLog(@"Spawning thread for %@", peer.ip);
	IndexDownloadThread* indexDownload = [[IndexDownloadThread alloc] initWithPeer:peer];
	[indexDownload start];
}

- (void) main {

	//boot strap
	NSString* bootstrapIP = @"129.22.160.130";
	NSString* bootstrapPort = @"59392";
	NSMutableString* url = [[NSMutableString alloc] init];
	[url appendFormat:@"http://%@:%@/peerlist", bootstrapIP, bootstrapPort];
	NSURL* peerURL = [NSURL URLWithString:url];

	NSData* peerlist = [NSData dataWithContentsOfURL:peerURL];
	NSArray* json = [NSJSONSerialization JSONObjectWithData:peerlist options:kNilOptions error:nil];

	for (int i = 0; i < json.count; i++) {
		NSString* ip = [json[i] objectForKey:@"IP"];
		NSNumber* indexHash = [json[i] objectForKey:@"IndexHash"];
		NSString* lastSeen = [json[i] objectForKey:@"LastSeen"];
		Peer* peer = [[Peer alloc] initWithIP:ip hash:indexHash timestamp:lastSeen];
		[self downloadIndexes:peer];
	}

}

@end
