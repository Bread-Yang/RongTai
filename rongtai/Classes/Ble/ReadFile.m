//
//  ReadFile.m
//  BLETool
//
//  Created by 林英琪 on 15/8/4.
//  Copyright (c) 2015年 Jaben. All rights reserved.
//

#import "ReadFile.h"

@implementation ReadFile

@synthesize aNoteDb,resultData;

- (id)init {
    self = [super init];
    //aNoteDb=[[NoteDb alloc]init];
    resultData = [[NSMutableData alloc] init];
    return self;
}

- (void)read:(NSString *)binName {
    //沙盒路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //文件名
    NSString *path = [[documentsDirectory stringByAppendingPathComponent:@"bin"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bin", binName]];
	
	if(![[NSFileManager defaultManager]fileExistsAtPath:path]){
     	//如果不存在
		return;
     }
	
	parentDirectoryPath = path;
	//异步输入流初始化，并把赋于地址
	asyncInputStream =
	[[NSInputStream alloc] initWithFileAtPath: parentDirectoryPath];
    //设置代理（回调方法、委托）
	[asyncInputStream setDelegate: self];
    //设置线程，添加线程，创建线程：Runloop顾名思义就是一个不停的循环，不断的去check输入
	[asyncInputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
								forMode:NSDefaultRunLoopMode];
    //打开线程
	[asyncInputStream open];
    
}
//追加数据
- (void)appendData:(NSData*)_data {
    [resultData appendData:_data];
}
//回调方法，不停的执行
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    BOOL shouldClose = NO;
    NSInputStream *inputStream = (NSInputStream*)theStream;
    //NSLog(@"as");
	switch (streamEvent) {
			
		case NSStreamEventHasBytesAvailable: {
            NSLog(@"读取文件 : %@", @"正在读取");

            //读数据
            //读取的字节长度
            NSInteger maxLength = 128;
            //缓冲区
			uint8_t readBuffer [maxLength];
            //从输出流中读取数据，读到缓冲区中
			NSInteger bytesRead = [inputStream read: readBuffer
										  maxLength:maxLength];
            //如果长度大于0就追加数据
			if (bytesRead > 0) {
                //把缓冲区中的数据读成data数据
				NSData *bufferData = [[NSData alloc]
									  initWithBytesNoCopy:readBuffer
									  length:bytesRead
									  freeWhenDone:NO];
				//追加数据
				[self appendData:bufferData];
				//release掉data
				
			}
			break;
		}
			
		case NSStreamEventErrorOccurred: {
            NSLog(@"读取文件 : %@", @"读取出错");
			//读的时候出错了
			NSError *error = [theStream streamError];
            shouldClose = YES;
			break;
		}
			
		case NSStreamEventEndEncountered: {
            shouldClose = YES;
			//数据读完就返回数据
			[self dataAtNoteDB];
			[theStream close];
			break;
		}
	}
	
    if (shouldClose) {
        //当文件读完或者是读到出错时，把线程移除
		[inputStream removeFromRunLoop: [NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
        //并关闭流
		[theStream close];
	}
}
- (void) dataAtNoteDB {
    NSLog(@"读取文件 : %@", resultData);
    
    //NSLog(@"%@",aNoteDb);
    /*
     for (id tmp in  aNoteDb.noteList.noteArray)
     {
     NSLog(@"tmp = %@",tmp);
     }
     */
}
- (NoteDb*)getNoteDb {
    return self.aNoteDb;
}
- (void)dealloc {
	
}

@end
