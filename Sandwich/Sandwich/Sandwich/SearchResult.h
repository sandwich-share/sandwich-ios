//
//  SearchResult.h
//  Sandwich
//
//  Created by Diego Waxemberg on 4/12/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peer.h"

@interface SearchResult : NSObject
@property Peer* peer;
@property NSString* filename;
@property NSString* filepath;

- (SearchResult*) initWithData: (NSString*)filename filepath: (NSString*)filepath peer:(Peer*)peer;

@end
