//
//  ViewController.h
//  Sandwich
//
//  Created by Diego Waxemberg on 4/10/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMusicPlayerController.h>
#import "Peer.h"

@interface ViewController : UITableViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchResults;
@property (strong, atomic) NSMutableArray* results;

- (void) addSearchResults:(NSString *)result peer:(Peer*)peer;
- (void) redraw;
- (void) clearResults;

@end
