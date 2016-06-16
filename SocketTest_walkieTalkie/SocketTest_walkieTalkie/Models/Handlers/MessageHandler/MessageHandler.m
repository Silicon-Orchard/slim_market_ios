//
//  MessageHandler.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "MessageHandler.h"
#import <UIKit/UIKit.h>

@implementation MessageHandler

+(MessageHandler*)sharedHandler{
    static MessageHandler *mySharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedHandler = [[MessageHandler alloc] init];
        // Do any other initialisation stuff here
    });
    
    return mySharedHandler;
}

-(NSString *)getUUID{
    return [[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS];
}



- (NSString *)getIPAddress {
    
#if TARGET_OS_SIMULATOR
    
    //Simulator
    
    return @"192.168.2.129";
    
#else
    
    // Device
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
#endif
}

-(NSString *)newChannelCreatedMessageWithChannelID:(int) channelID deviceName:(NSString *)deviceNameForChannel{
    
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS], deviceNameForChannel, [self getIPAddress ],[NSNumber numberWithInt:TYPE_CREATE_CHANNEL], [NSNumber numberWithInt:channelID], nil]
                                                                forKeys:[NSArray arrayWithObjects:JSON_KEY_DEVICE_ID, JSON_KEY_DEVICE_NAME, JSON_KEY_IP_ADDRESS, JSON_KEY_TYPE, JSON_KEY_CHANNEL, nil]];
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;

}

-(NSString *)createChatMessageWithChannelID:(int) channelID deviceName:(NSString *)deviceNameForChannel chatmessage:(NSString *)message{
    
    
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS], deviceNameForChannel, [self getIPAddress ],[NSNumber numberWithInt:TYPE_MESSAGE], [NSNumber numberWithInt:channelID], message,nil]
                                                                forKeys:[NSArray arrayWithObjects:JSON_KEY_DEVICE_ID, JSON_KEY_DEVICE_NAME,JSON_KEY_IP_ADDRESS, JSON_KEY_TYPE, JSON_KEY_CHANNEL,  JSON_KEY_MESSAGE,nil]];
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
    
}

-(NSString *)leaveChatMessageWithChannelID:(int)channelID deviceName:(NSString *)deviceNameForChannel{

    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS], deviceNameForChannel, [self getIPAddress ],[NSNumber numberWithInt:TYPE_LEFT_CHANNEL], [NSNumber numberWithInt:channelID], nil]
                                                                forKeys:[NSArray arrayWithObjects:JSON_KEY_DEVICE_ID, JSON_KEY_DEVICE_NAME,JSON_KEY_IP_ADDRESS, JSON_KEY_TYPE, JSON_KEY_CHANNEL, nil]];
    
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
}


-(NSString *)joinChannelCreatedMessageWithChannelID:(int) channelID deviceName:(NSString *)deviceNameForChannel{
    
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS], deviceNameForChannel, [self getIPAddress ],[NSNumber numberWithInt:TYPE_JOIN_CHANNEL], [NSNumber numberWithInt:channelID], nil]
                                                                forKeys:[NSArray arrayWithObjects:JSON_KEY_DEVICE_ID, JSON_KEY_DEVICE_NAME,JSON_KEY_IP_ADDRESS, JSON_KEY_TYPE, JSON_KEY_CHANNEL,  nil]];
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
    
}

-(NSString *)confirmJoiningForChannelID:(int)channelID channelName:(NSString *)channelhostName{
    Channel *blankChannel = [[Channel alloc] init];
    Channel *channelToJoin = [blankChannel geChannel:channelID];
    NSString *hostIP = [self getIPAddress];
    NSString *hostName = channelhostName;
    NSMutableArray *channelMembers = [[NSMutableArray alloc] initWithCapacity:channelToJoin.channelMemberIPs.count];
    for (int i =0 ; i<channelToJoin.channelMemberIPs.count; i++) {
        NSDictionary *channelMember = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[channelToJoin.channelMemberIPs objectAtIndex:i],[channelToJoin.channelMemberNamess objectAtIndex:i], nil] forKeys:[NSArray arrayWithObjects:JSON_KEY_IP_ADDRESS,JSON_KEY_DEVICE_NAME, nil]];
        [channelMembers addObject:channelMember];
    }
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS], hostName, [self getIPAddress ],[NSNumber numberWithInt:TYPE_CHANNEL_FOUND], [NSNumber numberWithInt:channelID], channelMembers,nil]
                                                                forKeys:[NSArray arrayWithObjects:JSON_KEY_DEVICE_ID, JSON_KEY_DEVICE_NAME,JSON_KEY_IP_ADDRESS, JSON_KEY_TYPE, JSON_KEY_CHANNEL, JSON_KEY_CHANNEL_MEMBERS, nil]];
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
    
    return NULL;

}


-(NSString *)requestInfoAtStartMessage{


    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS], [UIDevice currentDevice].name, [self getIPAddress ],[NSNumber numberWithInt:TYPE_REQUEST_INFO], nil]
                                                                forKeys:[NSArray arrayWithObjects:JSON_KEY_DEVICE_ID, JSON_KEY_DEVICE_NAME,JSON_KEY_IP_ADDRESS, JSON_KEY_TYPE,  nil]];
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
}

-(NSString *)acknowledgeDeviceInNetwork{
    
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS], [UIDevice currentDevice].name, [self getIPAddress ],[NSNumber numberWithInt:TYPE_RECEIVE_INFO], nil]
                                                                forKeys:[NSArray arrayWithObjects:JSON_KEY_DEVICE_ID, JSON_KEY_DEVICE_NAME,JSON_KEY_IP_ADDRESS, JSON_KEY_TYPE,  nil]];
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
    
    
}

-(NSString *)leftApplicationMessage {
    
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS], [UIDevice currentDevice].name, [self getIPAddress ],[NSNumber numberWithInt:TYPE_LEFT_APPLICATION], nil]
                                                                forKeys:[NSArray arrayWithObjects:JSON_KEY_DEVICE_ID, JSON_KEY_DEVICE_NAME, JSON_KEY_IP_ADDRESS, JSON_KEY_TYPE,  nil]];
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
}


-(NSString *)voiceMessageJSONStringWithAudioFileName:(NSString *)fileName{
    
    NSString *base64StringFromAudioFile = [[AudioFileHandler sharedHandler] bas64EncodedStringFromAudioFileDataWithFileName:fileName];
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS],[UIDevice currentDevice].name, [self getIPAddress ],[NSNumber numberWithInt:TYPE_VOICE_MESSAGE], base64StringFromAudioFile ,nil]
                                                                forKeys:[NSArray arrayWithObjects:JSON_KEY_DEVICE_ID, JSON_KEY_DEVICE_NAME,JSON_KEY_IP_ADDRESS, JSON_KEY_TYPE, JSON_KEY_VOICE_MESSAGE, nil]];
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
    
}

-(NSString *)voiceMessageJSONStringWithAudioFileName:(NSString *)fileName forChannel:(int)channelID{
    
    NSString *base64StringFromAudioFile = [[AudioFileHandler sharedHandler] bas64EncodedStringFromAudioFileDataWithFileName:fileName];
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIDevice currentDevice].name, base64StringFromAudioFile ,[NSNumber numberWithInt:channelID], nil]
                                                                forKeys:[NSArray arrayWithObjects: JSON_KEY_DEVICE_NAME, JSON_KEY_VOICE_MESSAGE, JSON_KEY_CHANNEL, nil]];
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
    
}

-(NSArray *)voiceMessageJSONStringInChunksWithAudioFileName:(NSString *)fileName{
   
    NSMutableArray *JSONStringArray = [[NSMutableArray alloc] init];
    NSArray *base64StringArrayFromAudioFile = [[AudioFileHandler sharedHandler] base64EncodedStringChunksOfDataForFile:fileName];
    for (int i = 0; i < base64StringArrayFromAudioFile.count; i++) {

        NSError * error = nil;
        
        NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIDevice currentDevice].name,[NSNumber numberWithInt:TYPE_VOICE_MESSAGE], [base64StringArrayFromAudioFile objectAtIndex:i], [NSNumber numberWithInt:i+1],[NSNumber numberWithInt:base64StringArrayFromAudioFile.count ] ,[NSNumber numberWithInt:2],nil]
                                                                    forKeys:[NSArray arrayWithObjects: JSON_KEY_DEVICE_NAME, JSON_KEY_TYPE, JSON_KEY_VOICE_MESSAGE, JSON_KEY_VOICE_MESSAGE_CURRENT_CHUNK, JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT, JSON_KEY_CHANNEL,  nil]];
        
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
        NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [JSONStringArray addObject:resultAsString];
    }
   
    
        return JSONStringArray;
    
}

-(NSString *)repeatVoiceMessageRequest{
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS], [UIDevice currentDevice].name, [self getIPAddress ],[NSNumber numberWithInt:TYPE_VOICE_MESSAGE_REPEAT_REQUEST], nil]
                                                                forKeys:[NSArray arrayWithObjects:JSON_KEY_DEVICE_ID, JSON_KEY_DEVICE_NAME,JSON_KEY_IP_ADDRESS, JSON_KEY_TYPE,  nil]];
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
}


-(NSArray *)voiceMessageJSONStringInChunksWithAudioFileName:(NSString *)fileName inChannel:(int)channelID{
    
    NSMutableArray *JSONStringArray = [[NSMutableArray alloc] init];
    NSArray *base64StringArrayFromAudioFile = [[AudioFileHandler sharedHandler] base64EncodedStringChunksOfDataForFile:fileName];
    
    for (int i = 0; i < base64StringArrayFromAudioFile.count; i++) {
        
        NSError * error = nil;
        
        NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIDevice currentDevice].name,[NSNumber numberWithInt:TYPE_VOICE_MESSAGE],
                                                                             [base64StringArrayFromAudioFile objectAtIndex:i], [NSNumber numberWithInt:i+1],
                                                                             [NSNumber numberWithInt:(int)base64StringArrayFromAudioFile.count ], [NSNumber numberWithInt:channelID],
                                                                             [[MessageHandler sharedHandler] getIPAddress], fileName, nil]
                                                                    forKeys:[NSArray arrayWithObjects: JSON_KEY_DEVICE_NAME, JSON_KEY_TYPE, JSON_KEY_VOICE_MESSAGE,
                                                                             JSON_KEY_VOICE_MESSAGE_CURRENT_CHUNK, JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT, JSON_KEY_CHANNEL,
                                                                             JSON_KEY_IP_ADDRESS,JSON_KEY_VOICE_MESSAGE_FILE_NAME, nil]];
        

        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
        NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [JSONStringArray addObject:resultAsString];
    }
    
    
    return JSONStringArray;
    
}

-(NSArray *)voiceStreamJSONStringInChunksWithAudioFileName:(NSString *)fileName inChannel:(int)channelID{
    
    NSMutableArray *JSONStringArray = [[NSMutableArray alloc] init];
    NSArray *base64StringArrayFromAudioFile = [[AudioFileHandler sharedHandler] base64EncodedStringChunksOfDataForFile:fileName];
    for (int i = 0; i < base64StringArrayFromAudioFile.count; i++) {

        NSError * error = nil;
        
        NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[UIDevice currentDevice].name,[NSNumber numberWithInt:TYPE_VOICE_STREAM], [base64StringArrayFromAudioFile objectAtIndex:i], [NSNumber numberWithInt:i+1],[NSNumber numberWithInt:base64StringArrayFromAudioFile.count ] ,[NSNumber numberWithInt:channelID],[[MessageHandler sharedHandler] getIPAddress], nil]
                                                                    forKeys:[NSArray arrayWithObjects: JSON_KEY_DEVICE_NAME, JSON_KEY_TYPE, JSON_KEY_VOICE_MESSAGE, JSON_KEY_VOICE_MESSAGE_CURRENT_CHUNK, JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT, JSON_KEY_CHANNEL, JSON_KEY_IP_ADDRESS, nil]];
        
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
        NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [JSONStringArray addObject:resultAsString];
    }
    
    
    return JSONStringArray;
    
}

-(NSString *)voiceStreamDataFromAudioBuffer:(NSData *)buffer inChannelID:(int)channelID{
    
    NSString *base64buffer = [buffer base64EncodedStringWithOptions:0];
    NSError * error = nil;
    
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:TYPE_VOICE_STREAM], base64buffer,[NSNumber numberWithInt:channelID], nil]
                                                                forKeys:[NSArray arrayWithObjects: JSON_KEY_TYPE, JSON_KEY_VOICE_MESSAGE,   JSON_KEY_CHANNEL, nil]];
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
}




-(NSString *)oneToOneChatRequestMessage{
    
    
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS], [UIDevice currentDevice].name, [self getIPAddress ],[NSNumber numberWithInt:TYPE_ONE_TO_ONE_CHAT_REQUEST], nil]
                                                                forKeys:[NSArray arrayWithObjects:JSON_KEY_DEVICE_ID, JSON_KEY_DEVICE_NAME,JSON_KEY_IP_ADDRESS, JSON_KEY_TYPE,  nil]];
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
}

-(NSString *)oneToOneChatAcceptMessage{
    
    
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS], [UIDevice currentDevice].name, [self getIPAddress ],[NSNumber numberWithInt:TYPE_ONE_TO_ONE_CHAT_ACCEPT], nil]
                                                                forKeys:[NSArray arrayWithObjects:JSON_KEY_DEVICE_ID, JSON_KEY_DEVICE_NAME,JSON_KEY_IP_ADDRESS, JSON_KEY_TYPE,  nil]];
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
}

-(NSString *)oneToOneChatDeclineMessage{
    
    
    NSDictionary * postDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS], [UIDevice currentDevice].name, [self getIPAddress ],[NSNumber numberWithInt:TYPE_ONE_TO_ONE_CHAT_DECLINE], nil]
                                                                forKeys:[NSArray arrayWithObjects:JSON_KEY_DEVICE_ID, JSON_KEY_DEVICE_NAME,JSON_KEY_IP_ADDRESS, JSON_KEY_TYPE,  nil]];
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
}




@end
