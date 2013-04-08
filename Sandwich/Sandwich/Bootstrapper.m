//
//  Bootstrapper.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/6/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "Bootstrapper.h"
#import "Peer.h"
#import "IndexDownloadThread.h"

@implementation Bootstrapper


- (void) downloadIndexes: (NSMutableSet*) peerlist {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryDirectory = [paths objectAtIndex:0];
	NSString *dataPath = [libraryDirectory stringByAppendingPathComponent:@"sandwich.db"];
	
	const char * dbPath = [dataPath UTF8String];
	NSError *error;
	NSFileManager* fileMgr = [NSFileManager defaultManager];
	if ([fileMgr removeItemAtPath:dataPath error:&error] != YES)
		NSLog(@"Unable to delete file: %@", [error localizedDescription]);
	
	sqlite3* indexDB;
	NSArray* downloadThreads;
	if (sqlite3_open(dbPath, &indexDB) == SQLITE_OK) {
		for (Peer* peer in peerlist) {
			NSLog(@"Spawning thread for %@", peer.ip);
			IndexDownloadThread* indexDownload = [[IndexDownloadThread alloc] initWithPeer:peer indexDB:indexDB];
			[downloadThreads arrayByAddingObject:indexDownload];
			[indexDownload start];
		}
	}
	else {
		NSLog(@"Could not open database.");
	}
	NSLog(@"Thread Count: %d", downloadThreads.count);
	for (IndexDownloadThread* dThread in downloadThreads) {
		NSLog(@"Peer: %@ Status: %d",dThread.peer.ip, dThread.isFinished);
		while (!dThread.isFinished)
			;
		NSLog(@"Peer: %@ Status: %d",dThread.peer.ip, dThread.isFinished);
	}
	//sqlite3_close(indexDB);
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

	NSMutableSet* peers = [[NSMutableSet alloc] init];
	for (int i = 0; i < json.count; i++) {
		NSString* ip = [json[i] objectForKey:@"IP"];
		NSNumber* indexHash = [json[i] objectForKey:@"IndexHash"];
		NSString* lastSeen = [json[i] objectForKey:@"LastSeen"];
		Peer* peer = [[Peer alloc] initWithIP:ip hash:indexHash timestamp:lastSeen];
		[peers addObject:peer];
	}

	[self downloadIndexes:peers];
	
}

@end
