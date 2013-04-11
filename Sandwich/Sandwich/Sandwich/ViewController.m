//
//  ViewController.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/10/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "ViewController.h"
#import "Search.h"
#import "Peerlist.h"

@interface ViewController () {
    NSOperationQueue* searchQueue;
    
}

@end

@implementation ViewController

- (void) addSearchResults:(NSString*) result {
    [self.results addObject:result];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    /* Configure the cell. */
    cell.textLabel.text = [self.results objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.results count];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self handleSearch:searchBar];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //[self handleSearch:searchBar];
}

- (void)handleSearch:(UISearchBar *)searchBar {
    NSLog(@"User searched for %@", searchBar.text);
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
    NSLog(@"Peerlist: %d", peerlist == NULL);
    Search* search = [[Search alloc]initWithSearchParam:searchBar.text tableViewController:self];
    for (Search* s in [searchQueue operations]) {
        [s cancel];
    }
    [searchQueue addOperation:search];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"User canceled search");
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
    for (Search* s in [searchQueue operations]) {
        [s cancel];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _searchBar.delegate = (id)self;
    _searchResults.delegate = (id)self;
    _searchResults.dataSource = (id) self;
    
    searchQueue = [[NSOperationQueue alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSearchBar:nil];
    [super viewDidUnload];
}
@end
