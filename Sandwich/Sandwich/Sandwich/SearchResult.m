//
//  SearchResult.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/12/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult

- (SearchResult*) initWithData:(NSString *)filename filepath:(NSString *)filepath peer:(Peer *)peer {
    _filename = filename;
    _filepath = filepath;
    _peer   = peer;
    return [super init];
}

@end
