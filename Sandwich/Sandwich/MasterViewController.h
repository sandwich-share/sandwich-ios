//
//  MasterViewController.h
//  Sandwich
//
//  Created by Diego Waxemberg on 4/8/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
