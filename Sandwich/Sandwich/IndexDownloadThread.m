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

@implementation IndexDownloadThread

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
	NSData* index = [NSData dataWithContentsOfURL:peerURL];
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
	char* errorMsg = "";
	NSMutableString* sqlStmnt = [[NSMutableString alloc] init];
	[sqlStmnt appendFormat:@"CREATE TABLE IF NOT EXISTS [%@] (filepath TEXT PRIMARY KEY NOT NULL)", self.peer.ip];
	const char* sqlStatement = [sqlStmnt UTF8String];
	//NSLog(@"%s", sqlStatement);
	int errorCode;
	if ((errorCode = sqlite3_exec(self.indexDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
		NSLog(@"Failed to create table: %d %@", errorCode, self.peer.ip);
		NSLog(@"ERROR MESSAGE: %s", sqlite3_errmsg(self.indexDB));
	}
	else {
		NSArray* list = [json objectForKey:@"List"];
		NSMutableString* stmnt = [[NSMutableString alloc]init];
		[stmnt appendFormat:@"INSERT OR REPLACE INTO [%@] (filepath) VALUES (?1)", self.peer.ip];
		const char* sql = [stmnt UTF8String];
		sqlite3_stmt* insertStatment;
		sqlite3_prepare_v2(self.indexDB, sql, -1, &insertStatment, NULL);
		for (int i = 0; i < list.count; i++) {
			NSDictionary* files = list[i];
			for (int i = 0; i < files.count; i++) {
				NSString* filename = [files objectForKey:@"FileName"];
				const char* fileName = [filename UTF8String];
				int errorCode;
				if ((errorCode = sqlite3_bind_text(insertStatment, 0, fileName, -1, SQLITE_STATIC)) != SQLITE_OK) {
					NSLog(@"Bind Error: %d", errorCode);
				}
				if (sqlite3_step(insertStatment) != SQLITE_OK) {
					NSLog(@"Inserting error: %s", errorMsg);
				}
			}
		}
	}
}

- (IndexDownloadThread *)initWithPeer:(Peer *)peer indexDB:(sqlite3*)indexDB {
	self.peer = peer;
	self.indexDB = indexDB;
	return [super init];
}
@end
