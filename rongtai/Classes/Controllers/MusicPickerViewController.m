//
//  MusicPickerViewcontrollerViewController.m
//  rongtai
//
//  Created by yoghourt on 5/28/15.
//  Copyright (c) 2015 William-zhang. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "MusicPickerViewController.h"

#import "MusicModel.h"

@interface MusicPickerViewController () {
	NSArray *alphabeticalIndexTitles;
	NSDictionary *songsDictionary;
}

@property (nonatomic, strong) UIRefreshControl* refreshControl;

@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;

@end

@implementation MusicPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
//	alphabeticalIndexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self
						action:@selector(refreshView:)
			  forControlEvents:UIControlEventValueChanged];
	[self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"松手更新数据"]];
	[self.musicTableView addSubview:self.refreshControl];
	
	self.musicTableView.sectionIndexColor = [UIColor blackColor];
	
	songsDictionary = [MusicModel getAllSongsDictionary];
	
	alphabeticalIndexTitles = [[songsDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    self.musicPlayer = [MPMusicPlayerController systemMusicPlayer];
//    [self.musicPlayer setQueueWithQuery:[MPMediaQuery songsQuery]];
//    [self.musicPlayer setQueueWithItemCollection:self.songsArray];
    [self.musicTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - refresh

-(void) refreshView:(UIRefreshControl *)refresh {
	refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"更新数据中..."];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"MMM d, h:mm a"];
	NSString *lastUpdated = [NSString stringWithFormat:@"上次更新日期 %@",
							 [formatter stringFromDate:[NSDate date]]];
	refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
	
	[refresh endRefreshing];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *sectionTitle = [alphabeticalIndexTitles objectAtIndex:section];
	NSArray *sectionSongs = [songsDictionary objectForKey:sectionTitle];
	return [sectionSongs count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [songsDictionary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseId = @"SONG_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];
    }
	
	NSString *sectionTitle = [alphabeticalIndexTitles objectAtIndex:indexPath.section];
	NSArray *sectionSongs = [songsDictionary objectForKey:sectionTitle];
    
    MPMediaItem *item = [sectionSongs objectAtIndex:indexPath.row];
    [cell.textLabel setText:[MusicModel getSongName:item]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@-%@", [MusicModel getSingerFrom:item], [MusicModel getAlbumNameFrom:item]]];
    cell.backgroundView = nil;
    cell.selectedBackgroundView = nil;
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return alphabeticalIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [alphabeticalIndexTitles indexOfObject:title];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [alphabeticalIndexTitles objectAtIndex:section];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *sectionTitle = [alphabeticalIndexTitles objectAtIndex:indexPath.section];
	NSArray *sectionSongs = [songsDictionary objectForKey:sectionTitle];
    
    MPMediaItem *selectMusic = [sectionSongs objectAtIndex:indexPath.row];
    NSString *songTitle = [selectMusic valueForProperty: MPMediaItemPropertyTitle];
    NSLog (@"歌曲名字是 : %@", songTitle);
    
//    [self.musicPlayer setQueueWithItemCollection:self.songsArray];
	
    [self.musicPlayer setNowPlayingItem:selectMusic];
    self.musicPlayer.repeatMode = MPMusicRepeatModeAll;
    self.musicPlayer.shuffleMode = MPMusicShuffleModeOff;
    [self.musicPlayer play];
}

#pragma mark - View Action

- (IBAction)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}
@end
