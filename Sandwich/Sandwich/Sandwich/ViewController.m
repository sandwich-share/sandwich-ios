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
#import "SearchResult.h"
#import "MyPlayer.h"

@interface ViewController () {
    NSOperationQueue* searchQueue;
    SearchResult* clickedResult;
}

@end

@implementation ViewController
@synthesize results;

- (void) clearResults {
    @synchronized (results) {
        [results removeAllObjects];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex]) {
        ///TODO: Check if it is a movie!
    MyPlayer* mp = [[MyPlayer alloc]initWithFile:clickedResult ViewController:self];
    [mp startPlaying];
    }
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    // Should change this so textLabel does not need to be the file path.
    clickedResult = [results objectAtIndex:indexPath.row];
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Filename"//clickedResult.filename
                                                      message:clickedResult.filepath
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:nil];
    [message addButtonWithTitle:@"Stream this file!"];
    [message show];
}

- (void) addSearchResults:(NSString*)result peer:(Peer*)peer {
    @synchronized (results) {
        [results addObject:[[SearchResult alloc]initWithData:result filepath:result peer:peer]];
    }
}

- (void) redraw {
    [self.tableView reloadData];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    cell.textLabel.text = ((SearchResult*)[results objectAtIndex:indexPath.row]).filepath;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [results count];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    [self handleSearch:searchBar];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //[self handleSearch:searchBar];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
}

- (void)handleSearch:(UISearchBar *)searchBar {
    NSLog(@"User searched for %@", searchBar.text);
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
    //NSLog(@"Peerlist: %d", peerlist == NULL);
    Search* search = [[Search alloc]initWithSearchParam:searchBar.text tableViewController:self];
    for (Search* s in [searchQueue operations]) {
        [s cancel];
    }
    [searchQueue addOperation:search];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    NSLog(@"User canceled search");
    searchBar.text = @"";
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
    for (Search* s in [searchQueue operations]) {
        [s cancel];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.searchBar.delegate = (id)self;
    self.searchResults.delegate = (id)self;
    self.searchResults.dataSource = (id) self;
    [self.searchResults setScrollsToTop:true];
    results = [[NSMutableArray alloc]init];
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
