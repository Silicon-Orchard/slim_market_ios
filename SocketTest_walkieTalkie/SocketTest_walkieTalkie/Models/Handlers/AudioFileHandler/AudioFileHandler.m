//
//  AudioFileHandler.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 5/5/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "AudioFileHandler.h"

@implementation AudioFileHandler

+(AudioFileHandler*)sharedHandler{
    static AudioFileHandler *mySharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedHandler = [[AudioFileHandler alloc] init];
        // Do any other initialisation stuff here
    });
    
    return mySharedHandler;
}



- (NSString *)pathToAudioFileFolder {
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                        NSUserDomainMask,
                                                                        YES) lastObject];
    NSString *audioFileFolder = [documentsDirectory stringByAppendingPathComponent:@"AudioFileFolder"];
    
    // Create the folder if necessary
    BOOL isDir = NO;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:audioFileFolder isDirectory:&isDir] && isDir == NO) {
        
        [fileManager createDirectoryAtPath:audioFileFolder
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:nil];
    }
    
    return audioFileFolder;
}

-(NSString *) getAudioFilePathOfFilaName:(NSString *) fileName {
    
    return [[self pathToAudioFileFolder] stringByAppendingPathComponent:fileName];
}



- (BOOL) deleteAudioFileFolder {
    
    NSString *audioFileFolder = [self pathToAudioFileFolder];
    
    return [[NSFileManager defaultManager] removeItemAtPath:audioFileFolder error:nil];
}

-(NSString *) saveAudioData:(NSData *)audioData asFileName:(NSString *)fileName inFolderPath:(NSString *)folderPath {
    
    NSString *audioFilePath = [folderPath stringByAppendingPathComponent:fileName];
    [audioData writeToFile:audioFilePath atomically:YES];
    
    //[[NSFileManager defaultManager] removeItemAtPath:audioFilePath error:&error];
    
    return audioFilePath;
}




-(NSArray *)findFiles:(NSString *)extension
{
    NSMutableArray *matches = [[NSMutableArray alloc]init];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *item;
    NSArray *contents = [manager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] error:nil];
    for (item in contents)
    {
        if ([[item pathExtension]isEqualToString:extension])
        {
            [matches addObject:item];
        }
    }
    
    return matches;
}


- (void)removeAudio:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:filename];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
//        UIAlertView *removedSuccessFullyAlert = [[UIAlertView alloc] initWithTitle:@"Congratulations:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
//        [removedSuccessFullyAlert show];
        
        NSLog(@"File deleted Successfully");

        
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    NSFileManager *fileMan = [NSFileManager defaultManager];
    
    NSLog(@"Documents directory: %@",
          [fileMan contentsOfDirectoryAtPath:documentsPath error:&error]);
}


-(NSDate *)getFileCreationDateOfFile:(NSString *)fileName{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    
    NSDictionary* attrs = [fm attributesOfItemAtPath:filePath error:nil];
    NSDate *creationDate;
    if (attrs != nil) {
        creationDate = (NSDate*)[attrs objectForKey: NSFileCreationDate];
        NSLog(@"Date Created: %@", [creationDate description]);
        return creationDate;
    }
    else {
        NSLog(@"Not found");
        return nil;
    }
    
}


-(NSData *)dataFromAudioFile:(NSString *)fileName{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:filePath];
    NSData *myData = [NSData dataWithContentsOfURL:soundFileURL];
    
    return myData;
}

-(NSString *)saveFileAndGetSavedFilePathInDocumentsDirectoryFromData:(NSData *)audioData saveDataAsFileName:(NSString *)fileName{
    
    NSString *docsDir;
    NSArray *dirPaths;
    NSError *error = nil;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:fileName]];
    [[NSFileManager defaultManager] removeItemAtPath:databasePath error:&error];
    [audioData writeToFile:databasePath atomically:YES];
    return databasePath;
    
}

- (NSString *)bas64EncodedStringFromAudioFileDataWithFileName: (NSString *)fileName {
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSData *zipFileData = [NSData dataWithContentsOfFile:filePath];
    
    NSString *base64String = [zipFileData base64EncodedStringWithOptions:0];
    
    return base64String;
    
    // Adding to JSON and upload goes here.
}


-(NSArray *)base64EncodedStringChunksOfDataForFile:(NSString *)fileName{
    
    NSString *audioFilePath = [self getAudioFilePathOfFilaName:fileName];
    
    NSData *zipFileData = [NSData dataWithContentsOfFile:audioFilePath];
    int index = 0;
    int totalLen = (int)[zipFileData length];
    NSMutableArray *dataChunks = [[NSMutableArray alloc ]init];
    NSMutableArray *chunkStringArray = [[NSMutableArray alloc] init];
    while (index < totalLen) {
        int space = (totalLen - index > CHUNKSIZE) ? CHUNKSIZE : totalLen - index;
        NSData *chunk = [zipFileData subdataWithRange:NSMakeRange(index, space)];
        [dataChunks addObject:chunk];
        index += CHUNKSIZE;
    }
    for (int i =0; i < dataChunks.count; i++) {
        [chunkStringArray addObject:[[dataChunks objectAtIndex:i] base64EncodedStringWithOptions:0]];
    }
    return chunkStringArray;
}



-(NSString *)returnFilePathAfterAppendingData:(NSData *)audioData toFileName:(NSString *)fileName{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSError *error = nil;
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];

    NSFileManager *fileMan = [NSFileManager defaultManager];
//    if (![fileMan fileExistsAtPath:filePath])
//    {
//        NSLog(@"File Doesn't Exist!");
//        return nil;
//    }
    NSString *searchFilename = fileName; // name of the PDF you are searching for
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:documentsDirectory];
    
    NSString *documentsSubpath =  [documentsPath stringByAppendingPathComponent:fileName];;
//    while (documentsSubpath = [direnum nextObject])
//    {
//        if (![documentsSubpath.lastPathComponent isEqual:searchFilename]) {
//            continue;
//        }
//        
//        NSLog(@"found %@", documentsSubpath);
//    }
    
    NSFileHandle *myHandle = [NSFileHandle fileHandleForUpdatingAtPath:documentsSubpath];
    if(myHandle == nil) {
        [[NSFileManager defaultManager] createFileAtPath:documentsSubpath contents:nil attributes:nil];
        myHandle = [NSFileHandle fileHandleForWritingAtPath:documentsSubpath];
    }
    else{
        [myHandle seekToEndOfFile];

    }
    [myHandle writeData: audioData];
    [myHandle closeFile];
    // [data writeToFile:appFile atomically:YES];
    // Show contents of Documents directory
//    NSFileManager *fileMan = [NSFileManager defaultManager];

    NSLog(@"Documents directory: %@",
          [fileMan contentsOfDirectoryAtPath:documentsPath error:&error]);
    return filePath;

}

@end
