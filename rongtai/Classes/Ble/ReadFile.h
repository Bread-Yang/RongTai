//
//  ReadFile.h
//  BLETool
//
//  Created by 林英琪 on 15/8/4.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NoteDb;

@interface ReadFile : NSObject<NSStreamDelegate> {
    //路径
    NSString *parentDirectoryPath;
    //异步输出流
    NSInputStream *asyncInputStream;
    //读出来的数据
    NSMutableData *resultData;
    //返回去的数据
    NoteDb *aNoteDb;
}

@property (nonatomic,retain) NoteDb *aNoteDb;
@property (nonatomic, retain) NSMutableData *resultData;

//开始读数据
- (void)read:(NSString *)binName;
//读出来的数据追加到resultData上
- (void)appendData:(NSData*)_data;
//
- (void)dataAtNoteDB;
//返回去的数据
- (NoteDb*)getNoteDb;

@end