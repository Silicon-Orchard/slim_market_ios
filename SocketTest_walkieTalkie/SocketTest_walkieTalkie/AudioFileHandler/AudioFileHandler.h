//
//  AudioFileHandler.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/5/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioFileHandler : NSObject

+(AudioFileHandler*)sharedHandler;
-(NSArray *)findFiles:(NSString *)extension;
- (void)removeAudio:(NSString *)filename;
-(NSDate *)getFileCreationDateOfFile:(NSString *)fileName;
-(NSData *)dataFromAudioFile:(NSString *)fileName;
-(NSString *)saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:(NSData *)audioData saveDataAsFileName:(NSString *)fileName;
- (NSString *)bas64EncodedStringFromAudioFileDataWithFileName: (NSString *)fileName;
-(NSArray *)base64EncodedStringChunksOfDataForFile:(NSString *)fileName;
-(NSString *)returnFilePathAfterAppendingData:(NSData *)audioData toFileName:(NSString *)fileName;

@end
