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
#import "DownloadController.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <AVFoundation/AVAudioSession.h>

@interface ViewController () {
    NSOperationQueue* searchQueue;
    Peer* peerWithClickedFile;
    NSString* clickedFilePath;
}

@end

@implementation ViewController

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex]) {
        NSString *videoURLString = [[NSString stringWithFormat:@"http://%@:%d/files/%@",peerWithClickedFile.ip,peerWithClickedFile.port,clickedFilePath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *videoURL = [NSURL URLWithString:videoURLString];
        NSLog(@"VideoURL: %@", videoURLString);
        MPMoviePlayerViewController *moviePlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        NSError* error;
        AVAudioSession* audioSession = [AVAudioSession sharedInstance];
        if (![audioSession setCategory:AVAudioSessionCategoryPlayback error:&error]) {
            NSLog(@"AVAudioSession setCategory failed: %@", [error localizedDescription]);
        }
        if (![audioSession setActive:YES error:&error]) {
            NSLog(@"AVAudioSession setActive:YES failed: %@", [error localizedDescription]);
        }
        [moviePlayerView.moviePlayer useApplicationAudioSession];
        [self presentMoviePlayerViewControllerAnimated:moviePlayerView];
    }
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    // Should change this so textLabel does not need to be the file path.
    clickedFilePath = [NSString stringWithFormat:@"%@",[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    peerWithClickedFile = [_peers objectAtIndex:indexPath.row];
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"FileName"
                                                      message:clickedFilePath
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:nil];
    [message addButtonWithTitle:@"Stream this shit!"];
    [message show];
}

- (void) addSearchResults:(NSString*) result peer:(Peer*)peer {
    [self.results addObject:result];
    [_peers addObject:peer];
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
    cell.textLabel.text = [self.results objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_results count];
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
    _searchBar.delegate = (id)self;
    _searchResults.delegate = (id)self;
    _searchResults.dataSource = (id) self;
    [_searchResults setScrollsToTop:true];
    self.results = [[NSMutableArray alloc]init];
    _peers = [[NSMutableArray alloc]init];
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
