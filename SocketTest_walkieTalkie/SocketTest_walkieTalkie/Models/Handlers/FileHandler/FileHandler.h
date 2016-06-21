//
//  FileHandler.h
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 6/21/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHandler : NSObject

+ (FileHandler*)sharedHandler;
+ (NSString*) getFileNameOfType:(int) type;


- (NSString *)pathToWalkieTalkieDirectory;
- (NSString *)pathToFileFolderOfType:(int)type;
- (NSString *)pathToFileWithFileName:(NSString *)fileName OfType:(int)type;

- (BOOL)deleteWalkieTalkieDirectory;
- (BOOL)deleteFileWithFileName:(NSString *)fileName OfType:(int)type;

- (NSString *)writeData:(NSData *)fileData toFileName:(NSString *)fileName ofType:(int)type;
- (NSData *)dataFromFilePath:(NSString *)filePath;

- (NSArray *)encodedStringChunksWithFile:(NSString *)fileName OfType:(int)type;



@end
