//
//  SearchManager.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/25/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchResults.h"

@interface SearchManager : NSObject

- (SearchResults*) performSearch:(NSString*)searchParams;

@end
