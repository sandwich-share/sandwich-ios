//
//  Bootstrapper.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/6/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "Bootstrapper.h"
#import "IndexDownloadThread.h"

@implementation Bootstrapper {
    BOOL finished;
    NSOperationQueue* bootstrapQueue;
}

- (void) downloadIndexes: (Peer*) peer {
    NSLog(@"Spawning thread for %@", peer.ip);
	IndexDownloadThread* indexDownload = [[IndexDownloadThread alloc] initWithPeer:peer];
	[bootstrapQueue addOperation:indexDownload];
}

- (void) main {
    bootstrapQueue = [[NSOperationQueue alloc]init];
	//boot strap
	NSString* bootstrapIP = @"107.21.226.221";
	unsigned short bootstrapPort = [IndexDownloadThread portForIP:bootstrapIP];
	NSMutableString* url = [[NSMutableString alloc] init];
	[url appendFormat:@"http://%@:%u/peerlist", bootstrapIP, bootstrapPort];
	NSURL* peerURL = [NSURL URLWithString:url];

	NSData* peerlist = [NSData dataWithContentsOfURL:peerURL];
	NSArray* json = [NSJSONSerialization JSONObjectWithData:peerlist options:kNilOptions error:nil];
    
	for (int i = 0; i < json.count; i++) {
		NSString* ip = [json[i] objectForKey:@"IP"];
		NSNumber* indexHash = [json[i] objectForKey:@"IndexHash"];
		NSString* lastSeen = [json[i] objectForKey:@"LastSeen"];
		Peer* peer = [[Peer alloc] initWithIP:ip hash:indexHash timestamp:lastSeen];
////////////////////////////////////////////////////////////////////
// TODO: Need to check timestamp before trying to download index. //
////////////////////////////////////////////////////////////////////
		[self downloadIndexes:peer];
        [self.peerList addObject:peer];
	}
    [bootstrapQueue waitUntilAllOperationsAreFinished];
    [self setFinished];
}

- (BOOL) isFinished {
    return finished;
}

- (void) setFinished {
    finished = true;
    NSLog(@"Bootstrapper is finished.");
}

- (Bootstrapper*) initWithPeerlist: (NSMutableSet*)peerList {
    self.peerList = peerList;
    return [super init];
}
@end
