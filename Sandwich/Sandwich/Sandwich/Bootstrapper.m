//
//  Bootstrapper.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/6/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "Bootstrapper.h"
#import "IndexDownloadThread.h"
#import "Peerlist.h"

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
	NSString* bootstrapIP = @"129.22.166.242";
    NSArray* ips = [self potentialBootstrappers];
    if (![self tryBootstrap:bootstrapIP]) {
        for (int i = 0; ![self tryBootstrap:[ips objectAtIndex:i]] && i < ips.count; i++) {
        }
    }
    for (Peer* p in peerlist) {
        [self downloadIndexes:p];
    }
    [bootstrapQueue waitUntilAllOperationsAreFinished];
    [self setFinished];
}

- (NSArray*) potentialBootstrappers {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *databaseDirectory = [paths objectAtIndex:0];
    NSFileManager* manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:databaseDirectory error:nil];
    NSMutableArray* bootsrapIPs = [[NSMutableArray alloc]init];
    for (NSString* f in fileList) {
        //NSLog(@"%@",f);
        if ([[[f componentsSeparatedByString:@"."] lastObject] isEqual:@"db"]) {
            [bootsrapIPs addObject:[f substringToIndex:[f length]-4]];
        }
    }
    return [NSArray arrayWithArray:bootsrapIPs];
}

- (BOOL) tryBootstrap:(NSString *)ip {
    NSString* urlString = [NSString stringWithFormat:@"http://%@:%d/peerlist",ip,[IndexDownloadThread portForPeer:ip]];
    NSURL* bootstrapURL = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:bootstrapURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *peerList = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if (peerList == NULL) {
        NSLog(@"Failed to bootstrap to: %@", ip);
        return FALSE;
    }
    else {
        NSLog(@"Successfully bootstrapped to: %@", ip);
        NSArray* json = [NSJSONSerialization JSONObjectWithData:peerList options:kNilOptions error:nil];
        
        for (int i = 0; i < json.count; i++) {
            NSString* ip = [json[i] objectForKey:@"IP"];
            NSNumber* indexHashNumber = [json[i] objectForKey:@"IndexHash"];
            unsigned int indexHash = [indexHashNumber intValue];
            NSString* lastSeen = [json[i] objectForKey:@"LastSeen"];
            Peer* peer = [[Peer alloc] initWithIP:ip hash:indexHash timestamp:lastSeen];
            [peerlist addObject:peer];
        }
        return TRUE;
    }
}

- (BOOL) isFinished {
    return finished;
}

- (void) setFinished {
    finished = true;
    NSLog(@"Bootstrapper is finished.");
}

@end
