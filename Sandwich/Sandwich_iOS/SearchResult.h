//
//  SearchResult.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 9/7/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peer.h"

@interface SearchResult : NSObject

- (id) initWithPeer:(Peer*)peer filePath:(NSString*)filePath;
- (NSString*) getFilePath;
- (Peer*) getPeer;

@end
