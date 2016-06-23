//
//  FileHandler.m
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 6/21/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "FileHandler.h"

@implementation FileHandler

+(FileHandler*)sharedHandler{
    static FileHandler *mySharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedHandler = [[FileHandler alloc] init];
        // Do any other initialisation stuff here
    });
    
    return mySharedHandler;
}

- (instancetype)init{
    
    if(self = [super init]){
        
        
    }
    return self;
}

#pragma mark - Path Helper

+ (NSString*) getFileNameOfType:(int) type{
    
    NSString *extension = @"";
    
    switch (type) {
        case kFileTypeAudio:
            extension = @".caf";
            break;
        case kFileTypeVideo:
            extension = @".mp4";
            break;
        case kFileTypePhoto:
            extension = @".png";
            break;
        case kFileTypeOthers:
            extension = @"";
            break;
            
        default:
            break;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyyMMddHHmmss"];
    NSString *stringFromDate = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@%@",stringFromDate, extension];
    
    return fileName;
}

- (NSString *)pathToWalkieTalkieDirectory {
 
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                        NSUserDomainMask,
                                                                        YES) lastObject];
    
    NSString *fileFolder = [documentsDirectory stringByAppendingPathComponent:@"Walkie-Talkie"];
    
    // Create the folder if necessary
    BOOL isDir = NO;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:fileFolder isDirectory:&isDir] && isDir == NO) {
        
        [fileManager createDirectoryAtPath:fileFolder
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:nil];
    }
    
    return fileFolder;
}



- (NSString *)pathToFileFolderOfType:(int)type {
    
    NSString *fileFolder;
    NSString *walkieTakieDirectory = [self pathToWalkieTalkieDirectory];
    
    
    switch (type) {
        case kFileTypeAudio:
            fileFolder = [walkieTakieDirectory stringByAppendingPathComponent:@"Audio"];
            break;
        case kFileTypeVideo:
            fileFolder = [walkieTakieDirectory stringByAppendingPathComponent:@"Video"];
            break;
        case kFileTypePhoto:
            fileFolder = [walkieTakieDirectory stringByAppendingPathComponent:@"Photo"];
            break;
        case kFileTypeOthers:
            fileFolder = [walkieTakieDirectory stringByAppendingPathComponent:@"Others"];
            break;
            
        default:
            return @"";
            break;
    }
    
    // Create the folder if necessary
    BOOL isDir = NO;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:fileFolder isDirectory:&isDir] && isDir == NO) {
        
        [fileManager createDirectoryAtPath:fileFolder
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:nil];
    }
    
    return fileFolder;
}

- (NSString *)pathToFileWithFileName:(NSString *)fileName OfType:(int)type {
    
    return [[self pathToFileFolderOfType:type] stringByAppendingPathComponent:fileName];
}

#pragma mark - Delete

- (BOOL)deleteWalkieTalkieDirectory {
    
    NSString *walkieTalkieDirectory = [self pathToWalkieTalkieDirectory];
    
    return [[NSFileManager defaultManager] removeItemAtPath:walkieTalkieDirectory error:nil];
}

- (BOOL)deleteFileWithFileName:(NSString *)fileName OfType:(int)type {
    
    NSString *filePath = [self pathToFileWithFileName:fileName OfType:type];
    
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}


#pragma mark - Write & Read Data

- (NSString *)writeData:(NSData *)fileData toFileName:(NSString *)fileName ofType:(int)type {
    
    NSString *filePath = [self pathToFileWithFileName:fileName OfType:type];
    
    BOOL success = [fileData writeToFile:filePath atomically:YES];
    
    return filePath;
}

-(NSData *)dataFromFilePath:(NSString *)filePath{
    
    NSURL *filePathURL = [NSURL fileURLWithPath:filePath];
    NSData *myData = [NSData dataWithContentsOfURL:filePathURL];
    
    return myData;
}



-(NSArray *)encodedStringChunksWithFile:(NSString *)fileName OfType:(int)type{
    
    
    switch (type) {
        case kFileTypeAudio:
            
            break;
        case kFileTypeVideo:

            break;
        case kFileTypePhoto:
            
            break;
        case kFileTypeOthers:
            
            break;
            
        default:

            break;
    }
    
    
    NSString *filePath = [self pathToFileWithFileName:fileName OfType:type];
    NSData *fileData = [self dataFromFilePath:filePath];
    
    printf("File Data Lenth : %u", [fileData length]);
    
    
    int index = 0;
    int totalLen = (int)[fileData length];
    
    NSMutableArray *dataChunks = [[NSMutableArray alloc ]init];
    NSMutableArray *chunkStringArray = [[NSMutableArray alloc] init];
    
    while (index < totalLen) {
        
        int space = (totalLen - index > CHUNKSIZE) ? CHUNKSIZE : totalLen - index;
        
        NSData *chunk = [fileData subdataWithRange:NSMakeRange(index, space)];
        [dataChunks addObject:chunk];
        index += CHUNKSIZE;
    }
    
    for (int i =0; i < dataChunks.count; i++) {
        [chunkStringArray addObject:[[dataChunks objectAtIndex:i] base64EncodedStringWithOptions:0]];
    }
    
    return chunkStringArray;
}


@end
