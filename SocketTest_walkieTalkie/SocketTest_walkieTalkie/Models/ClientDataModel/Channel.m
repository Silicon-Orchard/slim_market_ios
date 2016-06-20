//
//  Channel.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "Channel.h"

@implementation Channel

-(id)initWithChannelID:(int)channelID {
    if ( self = [super init] ) {
        self.channelID = channelID;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    //Encode the properties of the object
    [encoder encodeInt:self.channelID forKey:@"channelID"];
    [encoder encodeObject:self.channelMemberIDs forKey:@"channelMemberIDs"];
    [encoder encodeObject:self.channelMemberIPs forKey:@"channelMemberIPs"];
    [encoder encodeObject:self.channelMemberNamess forKey:@"channelMemberNamess"];
    [encoder encodeObject:self.foreignChannelHostDeviceID forKey:@"foreignChannelHostDeviceID"];
    [encoder encodeObject:self.foreignChannelHostIP forKey:@"foreignChannelHostIP"];
    [encoder encodeObject:self.foreignChannelHostName forKey:@"foreignChannelHostName"];



}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if ( self != nil )
    {
        //decode the properties
        self.channelID = [decoder decodeIntForKey:@"channelID"];
        self.channelMemberIDs = [decoder decodeObjectForKey:@"channelMemberIDs"];
        self.channelMemberIPs = [decoder decodeObjectForKey:@"channelMemberIPs"];
        self.channelMemberNamess = [decoder decodeObjectForKey:@"channelMemberNamess"];
        self.foreignChannelHostName = [decoder decodeObjectForKey:@"foreignChannelHostName"];
        self.foreignChannelHostDeviceID = [decoder decodeObjectForKey:@"foreignChannelHostDeviceID"];
        self.foreignChannelHostIP = [decoder decodeObjectForKey:@"foreignChannelHostIP"];


    }
    return self;
}

-(void)saveChannel:(Channel *)channelToSave{
    
    NSMutableArray *channels = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS];
    if (!channels) {
        NSData *channelData = [NSKeyedArchiver archivedDataWithRootObject:channelToSave];
        NSMutableArray *channelList =   [ [NSMutableArray alloc] initWithObjects:channelData, nil];
        [[NSUserDefaults standardUserDefaults] setObject:channelList forKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        NSMutableArray *mutableChannels = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS]];
        NSData *channelData = [NSKeyedArchiver archivedDataWithRootObject:channelToSave];
        [mutableChannels addObject:channelData];
        [[NSUserDefaults standardUserDefaults] setObject:mutableChannels forKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
}


-(void)saveForeignChannel:(Channel *)channelToSave{
    
    NSMutableArray *channels = [[NSUserDefaults standardUserDefaults] objectForKey:FOREIGN_NEWLYCREATED_CHANNELS_KEY_FOR_USERDEFAULS];
    if (!channels) {
        NSData *channelData = [NSKeyedArchiver archivedDataWithRootObject:channelToSave];
        NSMutableArray *channelList =   [ [NSMutableArray alloc] initWithObjects:channelData, nil];
        [[NSUserDefaults standardUserDefaults] setObject:channelList forKey:FOREIGN_NEWLYCREATED_CHANNELS_KEY_FOR_USERDEFAULS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        NSMutableArray *mutableChannels = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:FOREIGN_NEWLYCREATED_CHANNELS_KEY_FOR_USERDEFAULS]];
        NSData *channelData = [NSKeyedArchiver archivedDataWithRootObject:channelToSave];
        [mutableChannels addObject:channelData];
        [[NSUserDefaults standardUserDefaults] setObject:mutableChannels forKey:FOREIGN_NEWLYCREATED_CHANNELS_KEY_FOR_USERDEFAULS];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}


-(Channel *)geChannel:(int)channelID{
    NSMutableArray *channels = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS];
    if (channels) {
        for (NSData *channelData in channels) {
            Channel *savedChannel = (Channel *)[NSKeyedUnarchiver unarchiveObjectWithData: channelData];
            if (savedChannel.channelID == channelID) {
                return savedChannel;
            }

        }
    }
    return nil;
}

-(Channel *)getForeignChannel:(int)channelID{
    
    NSMutableArray *channels = [[NSUserDefaults standardUserDefaults] objectForKey:FOREIGN_NEWLYCREATED_CHANNELS_KEY_FOR_USERDEFAULS];
    if (channels) {
        for (NSData *channelData in channels) {
            Channel *savedChannel = (Channel *)[NSKeyedUnarchiver unarchiveObjectWithData: channelData];
            if (savedChannel.channelID == channelID) {
                return savedChannel;
            }
        }
    }
    return nil;
}


-(void)addUserToChannelWithChannelID:(int)channelID userIP:(NSString *)userIP userName:(NSString *)userName userID:(NSString *)userID{
    NSMutableArray *channels = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS]];
//    NSMutableArray *channels = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS];
    if (channels) {
       
        for (int i = 0; i<channels.count; i++) {
            NSData *channelData = [channels objectAtIndex:i];
            Channel *savedChannel = (Channel *)[NSKeyedUnarchiver unarchiveObjectWithData: channelData];
            if (savedChannel.channelID == channelID) {
                
                if (!savedChannel.channelMemberIDs) {
                    savedChannel.channelMemberIDs = [[NSMutableArray alloc] initWithObjects:userID, nil];
                }
                else{
                    [savedChannel.channelMemberIDs addObject:userID];
                }
                
                if (!savedChannel.channelMemberIPs) {
                    savedChannel.channelMemberIPs = [[NSMutableArray alloc] initWithObjects:userIP, nil];
                }
                else{
                    [savedChannel.channelMemberIPs addObject:userIP];
                }
                
                if (!savedChannel.channelMemberNamess) {
                    savedChannel.channelMemberNamess = [[NSMutableArray alloc] initWithObjects:userName, nil];
                }
                else{
                    [savedChannel.channelMemberNamess addObject:userName];
                }
                NSData *newSavedChannel = [NSKeyedArchiver archivedDataWithRootObject:savedChannel];
                [channels replaceObjectAtIndex:i withObject:newSavedChannel];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:channels forKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

}

-(void)addUserToForeignChannelWithChannelID:(int)channelID userIP:(NSString *)userIP userName:(NSString *)userName userID:(NSString *)userID{
    NSMutableArray *channels = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:FOREIGN_NEWLYCREATED_CHANNELS_KEY_FOR_USERDEFAULS]];
    //    NSMutableArray *channels = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS];
    if (channels) {
        
        for (int i = 0; i<channels.count; i++) {
            NSData *channelData = [channels objectAtIndex:i];
            Channel *savedChannel = (Channel *)[NSKeyedUnarchiver unarchiveObjectWithData: channelData];
            if (savedChannel.channelID == channelID) {
                
                if (!savedChannel.channelMemberIDs) {
                    savedChannel.channelMemberIDs = [[NSMutableArray alloc] initWithObjects:userID, nil];
                }
                else{
                    [savedChannel.channelMemberIDs addObject:userID];
                }
                
                if (!savedChannel.channelMemberIPs) {
                    savedChannel.channelMemberIPs = [[NSMutableArray alloc] initWithObjects:userIP, nil];
                }
                else{
                    [savedChannel.channelMemberIPs addObject:userIP];
                }
                
                if (!savedChannel.channelMemberNamess) {
                    savedChannel.channelMemberNamess = [[NSMutableArray alloc] initWithObjects:userName, nil];
                }
                else{
                    [savedChannel.channelMemberNamess addObject:userName];
                }
                NSData *newSavedChannel = [NSKeyedArchiver archivedDataWithRootObject:savedChannel];
                [channels replaceObjectAtIndex:i withObject:newSavedChannel];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:channels forKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}


-(void)replaceForeignChannelOfID:(int)channelID withChannel:(Channel *)channel{
    NSMutableArray *channels = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:FOREIGN_NEWLYCREATED_CHANNELS_KEY_FOR_USERDEFAULS]];
    //    NSMutableArray *channels = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS];
    if (channels) {
        
        for (int i = 0; i<channels.count; i++) {
            NSData *channelData = [channels objectAtIndex:i];
            Channel *savedChannel = (Channel *)[NSKeyedUnarchiver unarchiveObjectWithData: channelData];
            if (savedChannel.channelID == channelID) {
                NSData *newSavedChannel = [NSKeyedArchiver archivedDataWithRootObject:channel];
                [channels replaceObjectAtIndex:i withObject:newSavedChannel];
            }
        }
    }

    [[NSUserDefaults standardUserDefaults] setObject:channels forKey:FOREIGN_NEWLYCREATED_CHANNELS_KEY_FOR_USERDEFAULS];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

-(void)replaceChannelOfID:(int)channelID withChannel:(Channel *)channel{
    NSMutableArray *channels = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS]];
    
    //    NSMutableArray *channels = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS];
    if (channels) {
        
        for (int i = 0; i<channels.count; i++) {
            NSData *channelData = [channels objectAtIndex:i];
            Channel *savedChannel = (Channel *)[NSKeyedUnarchiver unarchiveObjectWithData: channelData];
            if (savedChannel.channelID == channelID) {
                NSData *newSavedChannel = [NSKeyedArchiver archivedDataWithRootObject:channel];
                [channels replaceObjectAtIndex:i withObject:newSavedChannel];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:channels forKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)removeChannelWithChannelID:(int)channelID{
    NSMutableArray *channels = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS]];
    NSMutableArray *foreignChannels = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:FOREIGN_NEWLYCREATED_CHANNELS_KEY_FOR_USERDEFAULS]];

    //    NSMutableArray *channels = [[NSUserDefaults standardUserDefaults] objectForKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS];
    if (channels) {
        
        for (int i = 0; i<channels.count; i++) {
            NSData *channelData = [channels objectAtIndex:i];
            Channel *savedChannel = (Channel *)[NSKeyedUnarchiver unarchiveObjectWithData: channelData];
            if (savedChannel.channelID == channelID) {
                [channels removeObjectAtIndex:i];
                
            }
        }
    }
    if (foreignChannels) {
        
        for (int i = 0; i<foreignChannels.count; i++) {
            NSData *channelData = [foreignChannels objectAtIndex:i];
            Channel *savedChannel = (Channel *)[NSKeyedUnarchiver unarchiveObjectWithData: channelData];
            if (savedChannel.channelID == channelID) {
                [foreignChannels removeObjectAtIndex:i];
                
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:channels forKey:SAVED_CHANNELS_KEY_FOR_USERDEFAULS];
    [[NSUserDefaults standardUserDefaults] setObject:foreignChannels forKey:FOREIGN_NEWLYCREATED_CHANNELS_KEY_FOR_USERDEFAULS];

    [[NSUserDefaults standardUserDefaults] synchronize];

}



@end
