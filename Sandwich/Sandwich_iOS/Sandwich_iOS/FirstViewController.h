//
//  FirstViewController.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/24/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UITableViewController <UISearchBarDelegate, UITableViewDelegate>

@property NSMutableArray* searchResults;

- (void) setResults:(NSMutableArray*)results;

@end
