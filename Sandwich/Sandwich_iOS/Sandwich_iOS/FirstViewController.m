//
//  FirstViewController.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/24/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "FirstViewController.h"
#import "SearchManager.h"
#import "MainHandler.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.searchResults == NULL) {
        self.searchResults = [[NSMutableArray alloc] init];
    }
    [self.searchResults removeAllObjects];
    NSLog(@"Searching for: %@", searchBar.text);
    [self.view endEditing:TRUE];
    SearchManager* sm = [MainHandler getSearchManager];
    [sm performSearch:searchBar.text viewController:self];
    
}

- (void)setResults:(NSMutableArray *)results {
    [self setSearchResults:results];
    [(UITableView*)self.view reloadData];
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SearchManager* sMan = [MainHandler getSearchManager];
    return [sMan getResults].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    /* Configure the cell. */
    cell.textLabel.text = [(SearchResult*)[self.searchResults objectAtIndex:indexPath.row] getFilePath];
    
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
