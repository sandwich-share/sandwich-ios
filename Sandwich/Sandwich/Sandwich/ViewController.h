//
//  ViewController.h
//  Sandwich
//
//  Created by Diego Waxemberg on 4/10/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UITableViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchResults;
@property NSMutableArray* results;

- (void) addSearchResults:(NSString *)result;
@end
