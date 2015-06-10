//
//  MusicModel.h
//  SilverlitCar
//
//  Created by J on 12-7-10.
//  Copyright (c) 2012年 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "PinYinUti.h"


@interface MusicModel : NSObject {
    
}

#pragma mark - GetAll info

+ (NSArray *) getAllPodcasts;

+ (NSArray *) getAllComposers;

+ (NSArray *) getAllCompilations;

+ (NSArray *) getAllGenres;

+ (NSArray *) getAllAudiobooks;

+ (NSArray *) getAllSong; //返回 按首字母排列  array {Item ,Item,Item,Item,Item}

+ (NSArray*) getAllPlaylistName;

+ (NSArray*) getAllPlaylistWithItem;

+ (NSArray*) getAllAlbumWithOneItem;

+ (NSArray *) getAllArtistsItem;

+ (NSArray*) getAllAlbum; //返回 专辑数组 ｛ 歌曲数组 {MPMediaItem} ｝

+ (NSArray*) getAllAlbumArtwork:(NSArray *)albums withSize:(CGSize)size; //返回 专辑封面数组 {UIImage}

+ (NSArray*) getAllAlbumName;//返回 专辑名字数组 {NSString}

+ (int) getALLAlbumCount; //返回所有专辑数目

+ (NSArray*) getAlbumWithAlbumName:(NSString *)albumName; //用专辑里的item去找整首专辑回来。

+ (NSArray*) getAlbumWithAlbumItem:(MPMediaItem*)albumItem; //这个比较好用。。。

#pragma mark - GetAlbum info
+ (NSArray*) getSongsNamesFromAlbum:(NSArray*)album;    //return  {NSString}
+ (NSArray*) getSongsDurationsFromAlbum:(NSArray*)album;  //return {NSString}  00:00


#pragma mark - GetSingle info
+ (unsigned long long) getItemIdFrom:(MPMediaItem*)item;
+ (char ) getItemFirstChar:(MPMediaItem*)item;
+ (UIImage*) getImageFrom:(MPMediaItem*)item size:(CGSize)size;
+ (NSString*) getSingerFrom:(MPMediaItem*)item;
+ (NSString*) getAlbumNameFrom:(MPMediaItem*)item;
+ (NSString*) getSongName:(MPMediaItem*)item;
+ (NSString*) getSongDurationStr:(MPMediaItem*)item;
+ (NSString*) getDurationStrFromCurrentDuration:(int)time;
+ (NSTimeInterval) getItemDuration:(MPMediaItem*)item; //返回



@end
