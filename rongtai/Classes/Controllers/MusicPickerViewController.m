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

@interface MusicPickerViewController ()

@property NSArray *songsArray;

@property (nonatomic, strong) UIRefreshControl* refreshControl;

@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;

@end

@implementation MusicPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self
						action:@selector(refreshView:)
			  forControlEvents:UIControlEventValueChanged];
	[self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"松手更新数据"]];
	[self.musicTableView addSubview:self.refreshControl];
    
    self.musicPlayer = [MPMusicPlayerController systemMusicPlayer];
//    [self.musicPlayer setQueueWithQuery:[MPMediaQuery songsQuery]];
    self.songsArray = [[NSArray alloc]initWithArray:[MusicModel getAllSong]];
//    [self.musicPlayer setQueueWithItemCollection:self.songsArray];
    [self.musicTableView reloadData];
    
    MPMediaQuery *everything = [MPMediaQuery songsQuery];
    
    NSLog(@"Logging items from a generic query...");
    NSArray *itemsFromGenericQuery = [everything items];
    for (MPMediaItem *song in itemsFromGenericQuery) {
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        NSLog (@"%@", songTitle);
    }
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
//    if (section == 0) {
//        return 1;
//    } else {
//        return [[self.songsArray objectAtIndex:section - 1] count];
//    }

    return [[self.songsArray objectAtIndex:section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.songsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseId = @"SONG_CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseId];
    }
    
    MPMediaItem *item = [[self.songsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell.textLabel setText:[MusicModel getSongName:item]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@-%@", [MusicModel getSingerFrom:item], [MusicModel getAlbumNameFrom:item]]];
    cell.backgroundView = nil;
    cell.selectedBackgroundView = nil;
    
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *sectionTitleArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.songsArray count]; i++) {
        MPMediaItem *item = [[self.songsArray objectAtIndex:i] objectAtIndex:0];
        int firstChar = [MusicModel getItemFirstChar:item];
        NSString *sectionTitle = [NSString stringWithFormat:@"%c", firstChar];
        NSLog(@"sectionTitle : %@", sectionTitle);
        [sectionTitleArray addObject:sectionTitle];
    }
    return sectionTitleArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    MPMediaItem *item = [[self.songsArray objectAtIndex:section] objectAtIndex:0];
    int firtChar = [MusicModel getItemFirstChar:item];
    return [NSString stringWithFormat:@"%c", firtChar];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == [self.songsArray count]) {
        return 44;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    MPMediaQuery *allSongs = [MPMediaQuery songsQuery];
//	NSArray *itemsFromGenericQuery = [allSongs items];
//    MPMediaItem *selectMusic = [itemsFromGenericQuery objectAtIndex:indexPath.section];
    
    MPMediaItem *selectMusic = [[self.songsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *songTitle = [selectMusic valueForProperty: MPMediaItemPropertyTitle];
    NSLog (@"歌曲名字是 : %@", songTitle);
    
    [self.musicPlayer setQueueWithItemCollection:self.songsArray];
    
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
