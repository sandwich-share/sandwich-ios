//
//  SearchManager.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/25/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchResult.h"
#import "FirstViewController.h"

@interface SearchManager : NSObject

- (void) performSearch:(NSString*)searchParams viewController:(FirstViewController*)viewController;
- (void) addResult:(SearchResult*)result;
- (void) clearResults;
- (NSArray*) getResults;

@end
