//
//  IndexDownloadThread.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/6/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "IndexDownloadThread.h"
#import <sqlite3.h>
#import <CommonCrypto/CommonDigest.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

@implementation IndexDownloadThread {
    BOOL finished;
}

- (unsigned short) portForIP: (NSString*)ip {
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

- (void)main {
	//initialize index download
	NSMutableString* url = [[NSMutableString alloc] init];
	[url appendFormat:@"http://%@:%d/indexfor", self.peer.ip, [self portForIP:self.peer.ip]];
	NSURL* peerURL = [NSURL URLWithString:url];
	//NSData* index = [NSData dataWithContentsOfURL:peerURL];*/
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:peerURL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:1];
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *index = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if (index == NULL)
	{
		NSLog(@"Failed to get index for peer %@", self.peer.ip);
		return;
	}
	else
	{
		NSLog(@"Fetched index for peer %@", self.peer.ip);
	}
	NSDictionary* json = [NSJSONSerialization JSONObjectWithData:index options:kNilOptions error:nil];
	
   	int errorCode;
	char* errorMsg;
    
    sqlite3_stmt* statement;
    NSString *sqlStmt = [NSString stringWithFormat:@"DROP TABLE IF EXISTS [%@]", self.peer.ip];
	const char* sqlStatement = [sqlStmt UTF8String];

    if ((errorCode = sqlite3_exec(self.indexDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
        NSLog(@"Cannot drop table: %@", self.peer.ip);
    }
    sqlStatement = [[NSString stringWithFormat:@"CREATE TABLE [%@] (filepath TEXT PRIMARY KEY NOT NULL)",self.peer.ip] UTF8String];
    if ((errorCode = sqlite3_exec(self.indexDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
        NSLog(@"Cannot create table: %@ Error Code: %d Error Message: %s", self.peer.ip, errorCode, errorMsg);
    }
    else {
        NSLog(@"Successfully created table: %@", self.peer.ip);
        
        
        NSString* insertStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO [%@] (filepath) VALUES (?1)", self.peer.ip];
		const char* insertStatement = [insertStmt UTF8String];
        
		sqlite3_prepare_v2(self.indexDB, insertStatement, -1, &statement, NULL);
        
        
        NSArray* list = [json objectForKey:@"List"];
		for (int i = 0; i < list.count; i++) {
			NSDictionary* files = list[i];
            NSString* filename = [files objectForKey:@"FileName"];
			const char* fileName = [filename UTF8String];
			int errorCode;
			if ((errorCode = sqlite3_bind_text(statement, 1, fileName, -1, SQLITE_STATIC)) != SQLITE_OK) {
				NSLog(@"Bind Error: %d", errorCode);
			}
			if ((errorCode = sqlite3_step(statement)) != SQLITE_DONE) {
				NSLog(@"Inserting error: %d", errorCode);
			}
            //NSLog(@"Inserting: %@: %s", self.peer.ip, fileName);
            sqlite3_reset(statement);
        }
        NSLog(@"Finished adding index: %@", self.peer.ip);

    }
    [self setFinished];
}

- (void) setFinished {
    finished = true;
}

- (BOOL) isFinished {
    return finished;
}

-(void) initializeDatabase {
    ///// Create path to the database file /////
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString* dbFileName = [NSString stringWithFormat:@"%@.db", self.peer.ip];
    
	NSString *dataPath = [libraryDirectory stringByAppendingPathComponent:dbFileName];
    const char * dbPath = [dataPath UTF8String];
    ////////////////////////////////////////////
    
    //// Create the database /////
    sqlite3* indexDB;
    if (sqlite3_open(dbPath, &indexDB) == SQLITE_OK) {
        self.indexDB = indexDB;
    }
    else {
        NSLog(@"Unable to create database");
    }
}

- (IndexDownloadThread *)initWithPeer:(Peer *)peer {
	self.peer = peer;
    [self initializeDatabase];
	return [super init];
}
@end
