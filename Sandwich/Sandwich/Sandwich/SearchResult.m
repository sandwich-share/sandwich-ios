//
//  SearchResult.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/12/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult
@synthesize filename,filepath,peer;
- (SearchResult*) initWithData:(NSString *)name filepath:(NSString *)path peer:(Peer *)p {
    filename = name;
    filepath = path;
    peer   = p;
    return [super init];
}

@end
