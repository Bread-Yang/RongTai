//
//  MusicModel.m
//  SilverlitCar
//
//  Created by J on 12-7-10.
//  Copyright (c) 2012年 XPG. All rights reserved.
//

#import "MusicModel.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation MusicModel 

//+ (void) saveAddPlist:(NSArray*)playlistNames playlists:(NSArray*)playlists {
//    [[NSUserDefaults standardUserDefaults] setObject:playlistNames forKey:@"playlistNames"];
//    
//    for (int i = 0; i < [playlists count]; i ++) {
//        [[NSUserDefaults standardUserDefaults] setObject:[playlists objectAtIndex:i] forKey:[NSString stringWithFormat:@"playlist%d",i]];
//    }
//
//    BTLog(@"playlists%@",playlists);
//}
//
//+ (NSArray *)getAddPlaylistName {
//    
//    return [[NSUserDefaults standardUserDefaults] objectForKey:@"playlistNames"];
//}
//
//+ (NSArray *)getAddPlaylists {
//    NSMutableArray *array = [[[NSMutableArray alloc] init]autorelease];
//    for (int i = 0; i < [[MusicModel getAddPlaylistName ]count]; ++i) {
//        [array addObject:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"playlist%d",i]]];
//    }
////    NSArray *playlists = [[NSUserDefaults standardUserDefaults] objectForKey:@"playlists"];
//        BTLog(@"playlists%@",array);
//    return array;
//}

+ (NSArray *) getAllPodcasts {
    MPMediaQuery * query = [MPMediaQuery podcastsQuery];
    NSArray *songs = [query collections];
    NSMutableArray *items = [[NSMutableArray alloc]init];
    for(MPMediaItemCollection *playlist in songs) {
        [items addObject: playlist.items];
    }
    return items;
}

+ (NSArray *) getAllComposers {
    MPMediaQuery * query = [MPMediaQuery composersQuery];
    NSArray *songs = [query collections];
    NSMutableArray *items = [[NSMutableArray alloc]init];
    for(MPMediaItemCollection *playlist in songs) {
        [items addObject: playlist.items];
    }
    return items;
}

+ (NSArray *) getAllCompilations {
    MPMediaQuery * query = [MPMediaQuery compilationsQuery];
    NSArray *songs = [query collections];
    NSMutableArray *items = [[NSMutableArray alloc]init];
    for(MPMediaItemCollection *playlist in songs) {
        [items addObject: playlist.items];
    }
    return items;
}

+ (NSArray *) getAllGenres {
    MPMediaQuery * query = [MPMediaQuery genresQuery];
    NSArray *songs = [query collections];
    NSMutableArray *items = [[NSMutableArray alloc]init];
    for(MPMediaItemCollection *playlist in songs) {
        [items addObject: playlist.items];
    }
    return items;
}

+ (NSArray *) getAllAudiobooks {
    MPMediaQuery * query = [MPMediaQuery audiobooksQuery];
    NSArray *songs = [query collections];
    NSMutableArray *items = [[NSMutableArray alloc]init];
    for(MPMediaItemCollection *playlist in songs) {
        [items addObject: playlist.items];
    }
    return items;
}

+ (NSArray*) getAllAlbumWithOneItem {
    MPMediaQuery * query = [MPMediaQuery albumsQuery];
    NSArray *songs = [query collections];
    NSMutableArray *items = [[NSMutableArray alloc]init];
    for(MPMediaItemCollection *playlist in songs) {
        [items addObject: playlist.items];
    }
    
    return items;
}

+ (NSDictionary *) getAllSongsDictionary {
	MPMediaQuery *query = [MPMediaQuery songsQuery];
	NSArray *songs = [query collections];
	
	NSMutableDictionary *songsDictionary = [NSMutableDictionary dictionary];
	
	for (MPMediaItemCollection *playlist in songs) {
		NSString *firstChar = [NSString stringWithFormat:@"%c", [MusicModel getItemFirstChar:playlist.representativeItem]];
		NSMutableArray *songsArray = [songsDictionary objectForKey:firstChar];
		if (!songsArray) {
			songsArray = [[NSMutableArray alloc] init];
			[songsArray addObject:playlist.representativeItem];
			[songsDictionary setObject:songsArray forKey:firstChar];
		} else {
			[songsArray addObject:playlist.representativeItem];
		}
	}
	
	return songsDictionary;
}

+ (NSArray *) getAllSong {
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    NSArray *songs = [query collections];
    NSMutableArray *items = [[NSMutableArray alloc]init];
    int firstChar = 0;
    for(MPMediaItemCollection *playlist in songs) {
        int get = [MusicModel getItemFirstChar:playlist.representativeItem];
        NSMutableArray *letterArray;
        if (firstChar != get) { //新歌曲
            letterArray = [[NSMutableArray alloc]init];
            [letterArray addObject:playlist.representativeItem];
            [items addObject:letterArray];
            firstChar = get;
        } else {
            [letterArray addObject:playlist.representativeItem];
        }
        
//        [items addObject:playlist.representativeItem];
    }
    return items;
}

+ (NSArray*) getAllPlaylistWithItem {
    MPMediaQuery * query = [MPMediaQuery playlistsQuery];
    NSArray *playlists = [query collections];
    NSMutableArray *playLists_ = [[NSMutableArray alloc]init];
    for(MPMediaItemCollection *playlist in playlists) {
        
        NSMutableArray *items = [[NSMutableArray alloc]init];
        for (MPMediaItem *item in playlist.items) {
            if ([[item valueForProperty:MPMediaItemPropertyMediaType] intValue] == MPMediaTypeMusic ) {
                [items addObject:item];
            }
        }
        if ([items count] !=0) {
            [playLists_ addObject:items];
        }

    }
    return playLists_;
}

+ (NSArray *) getAllArtistsItem {
    MPMediaQuery * query = [MPMediaQuery artistsQuery];
    NSArray *playlists = [query collections];
    NSMutableArray *artists = [[NSMutableArray alloc]init];
    for(MPMediaItemCollection *playlist in playlists) {
        [artists addObject:playlist.items];
    }
    return artists;
}

+ (NSArray*) getAllPlaylistName {
    MPMediaQuery * query = [MPMediaQuery playlistsQuery];
    NSArray *playlists = [query collections];
    NSMutableArray *playLists = [[NSMutableArray alloc]init];
    for(MPMediaPlaylist *playlist in playlists) {
        NSMutableArray *items = [[NSMutableArray alloc]init];
        for (MPMediaItem *item in playlist.items) {
                if ([[item valueForProperty:MPMediaItemPropertyMediaType] intValue] == MPMediaTypeMusic ) {
                [items addObject:item];
            }
        }
        if ([items count] !=0) {
            NSString *name = [playlist valueForProperty:MPMediaPlaylistPropertyName];
            [playLists addObject:name];
        }
    }
    return playLists;
}

+ (NSArray*)getAllAlbum {
    MPMediaQuery * query = [MPMediaQuery albumsQuery];
    NSString *lastAlbum = @"Album name";
    NSMutableArray *albums = [[NSMutableArray alloc]init];
    NSMutableArray *songs;
    for (MPMediaItem *item in query.items) {
        NSString *currentAlbum = [MusicModel getAlbumNameFrom:item];
        if (currentAlbum == NULL) {
            
        }else {
            if (![lastAlbum isEqualToString:currentAlbum]) { //发现新专辑
                lastAlbum = [NSString stringWithString:currentAlbum];
                songs = [[NSMutableArray alloc]init];
                [albums addObject:songs];
                [songs addObject:item];    
            } else { //相同专辑
                [songs addObject:item];    
            }
        }
    }
    return albums;
    //枚举后，生成一个 albums 数组 
    
}

//用专辑名字去找专辑所有的歌曲。。。
+ (NSArray*) getAlbumWithAlbumName:(NSString *)albumName {
    NSMutableArray *album = [[NSMutableArray alloc]init];
    MPMediaQuery * query = [MPMediaQuery albumsQuery];
    for (MPMediaItem *item in query.items) {
        NSString *currentAlbum = [MusicModel getAlbumNameFrom:item];
        if ([albumName isEqualToString:currentAlbum]) {
            [album addObject:item];
        }
    }
    return album;
}

+ (NSArray*) getAlbumWithAlbumItem:(MPMediaItem*)albumItem  {
    return [MusicModel getAlbumWithAlbumName:[MusicModel getAlbumNameFrom:albumItem]];
}

+ (NSArray*) getAllAlbumArtwork:(NSArray *)albums withSize:(CGSize)size {
    NSMutableArray *albumArtworks = [[NSMutableArray alloc]init];
    for (NSArray *album in  albums) {
        [albumArtworks addObject:[MusicModel getImageFrom:[album objectAtIndex:0] size:size]];
    }
    return albumArtworks;
}
+ (NSArray*)getAllAlbumName {
    NSArray * albums = [MusicModel getAllAlbum];
    NSMutableArray *albumNames = [[NSMutableArray alloc]init];
    for (NSArray *album in  albums) {
        [albumNames addObject:[MusicModel getAlbumNameFrom:[album objectAtIndex:0]]];
    }
    return albumNames;
}

+ (int) getALLAlbumCount {
    return [[MusicModel getAllAlbum]count];
}


#pragma mark - GetAlbum info
+ (NSArray*) getSongsNamesFromAlbum:(NSArray*)album {
    NSMutableArray * titles = [[NSMutableArray alloc]init];
    for (MPMediaItem* item in album) {
        [titles addObject:[MusicModel getSongName:item]];
    }
    return titles;
}
+ (NSArray*) getSongsDurationsFromAlbum:(NSArray*)album {
    NSMutableArray * durations = [[NSMutableArray alloc]init];
    for (MPMediaItem* item in album) {
        NSString *duration = [MusicModel getSongDurationStr:item];
        [durations addObject:duration];
    }
    return durations;    
}

+(int)validateFirstLetter:(int)arg
{
    if ((arg >= 97)&& (arg <= 122)) {
        arg = arg - 32;
        return arg;
    }else if((arg >= 65)&& (arg <= 90))
    {
        return arg;
    }else if((arg >= 48)&& (arg <= 57))
    {
        return arg;
    }else{
        return -1;
    }
}

#pragma mark - Get Single

+ (char ) getItemFirstChar:(MPMediaItem*)item {
    NSString *songName = [MusicModel getSongName:item];
//    songName = [songName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *firstLetter = [songName substringWithRange:NSMakeRange(0, 1)];
    NSData *tempData = [firstLetter dataUsingEncoding:NSUTF16StringEncoding];
//    int num = 1;
    int get = 0;
    [tempData getBytes:&get range:NSMakeRange(2, 2)];
    get = pinyinFirstLetter(get);
    
//    while (([MusicModel validateFirstLetter:get] == -1) && (num < StrLength(songName) )) {
//        get = 0;
//        firstLetter = [songName substringWithRange:NSMakeRange(num, 1)];
//        tempData = [firstLetter dataUsingEncoding:NSUTF16StringEncoding];
//        [tempData getBytes:&get range:NSMakeRange(2, 2)];
//        get = pinyinFirstLetter(get);
//        num ++;
//    }
//  
//    if(num < StrLength(songName))
//    {
//        get = [MusicModel validateFirstLetter:get];
//    }
    
    get = get >= 97 ? get - 32 :get;
    return get;
}

//+ (UIImage*) getImageFrom:(MPMediaItem*)item size:(CGSize)size {
//    MPMediaItemArtwork *artwork = [item valueForProperty: MPMediaItemPropertyArtwork];  
//    UIImage *artworkImage =[artwork imageWithSize:size];
//    if (artworkImage) {  
//        artworkImage = [MusicModel scaleToSize:artworkImage size:size];
//        return artworkImage;
//    } else {  
//        UIImage *noArtworkImage = [UIImage imageNamed:@"AudioPlayerNoArtwork" withExtension:@"png"];
//        noArtworkImage = [MusicModel scaleToSize:noArtworkImage size:size];
//        return noArtworkImage;
//    }  
//    
//}


+ (unsigned long long) getItemIdFrom:(MPMediaItem*)item {
    unsigned long itemID = [[item valueForProperty: MPMediaItemPropertyPersistentID] longLongValue];
        return itemID;
}

+ (NSString*) getSingerFrom:(MPMediaItem*)item {
    NSString *singer = [item valueForProperty: MPMediaItemPropertyArtist];  
    if (singer) {
        return singer;
    } else {
        return @"UnKnown Singer";
    }
}
+ (NSString*) getAlbumNameFrom:(MPMediaItem*)item {
    NSString *album = [item valueForProperty: MPMediaItemPropertyAlbumTitle];
    if (album) {
        return album;
    } else {
        return @"UnKnown Album";
    }
}
+ (NSString*) getSongName:(MPMediaItem*)item {
    NSString *name = [item valueForProperty: MPMediaItemPropertyTitle];  
    if (name) {
        return name;
    } else {
        return @"UnKnown name";
    }    
}

+ (NSString*) getSongDurationStr:(MPMediaItem*)item {
    int time = [MusicModel getItemDuration:item];
    return [MusicModel getDurationStrFromCurrentDuration:time];
}

+ (NSString*) getDurationStrFromCurrentDuration:(int)time {
    int min = time / 60;
    int sec = time % 60;
    return [NSString stringWithFormat:@"%02d:%02d",min,sec];
}


+ (NSTimeInterval) getItemDuration:(MPMediaItem*)item {
    return [[item valueForProperty:MPMediaItemPropertyPlaybackDuration]doubleValue];
}
#pragma mark - uti
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{  
    // 创建一个bitmap的context 
    UIGraphicsBeginImageContext(size);  
    // 绘制改变大小的图片  
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];  
    // 从当前context中创建一个改变大小后的图片  
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();  
    // 使当前的context出堆栈  
    UIGraphicsEndImageContext();  
    // 返回新的改变大小后的图片  
    return scaledImage;  
}

@end
