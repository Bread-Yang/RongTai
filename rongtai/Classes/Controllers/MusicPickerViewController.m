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

@property (nonatomic, strong) MPMusicPlayerController *musicPlayer;

@end

@implementation MusicPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    _songsArray = [[NSArray alloc]initWithArray:[MusicModel getAllSong]];
    [self.musicTableView reloadData];
    
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    
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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == [self.songsArray count]) {
        return 44;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self.musicPlayer setQueueWithQuery: [MPMediaQuery songsQuery]];
//    MPMediaItem *item = [[MPMediaQuery songsQuery] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    [self.musicPlayer setNowPlayingItem:item];
//    [self.musicPlayer ]
//    [self.musicPlayer play];
}

#pragma mark - View Action

- (IBAction)backButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}
@end
