//
//  Search.h
//  Sandwich
//
//  Created by Diego Waxemberg on 4/8/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Peer.h"
#import "ViewController.h"

@interface Search : NSOperation 
@property NSString* searchParam;
@property ViewController* tableview;
@property NSOperationQueue* searchThreads;

- (Search*)initWithSearchParam: (NSString*)searchParam tableViewController:(ViewController*)tableView;
- (void) setFinished;

@end
