//
//  ChannelHandler.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "ChannelHandler.h"

@interface ChannelHandler ()

@property (nonatomic, strong) NSMutableArray * acceptedOponentUsers;

@end

@implementation ChannelHandler

+(ChannelHandler*)sharedHandler{
    static ChannelHandler *mySharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedHandler = [[ChannelHandler alloc] init];
        // Do any other initialisation stuff here
    });
    
    return mySharedHandler;
}

- (instancetype)init {
    if(self = [super init]){
        self.acceptedOponentUsers = [NSMutableArray new];
    }
    return self;
}

-(int)getCurrentlyActiveChatroom{
    return self.currentlyActiveChannelID;
}



- (BOOL)isAcceptedOponentUser:(User *) requesterUser {
    
    for (User *user in self.acceptedOponentUsers) {
        
        if([user.deviceID isEqualToString:requesterUser.deviceID] && [user.deviceIP isEqualToString:requesterUser.deviceIP]){
            
            return YES;
        }
    }
    
    return NO;
}

- (void)addOponetUserToAcceptedList:(User *) requesterUser{
    
    if(![self isAcceptedOponentUser:requesterUser]){
        
        [self.acceptedOponentUsers addObject:requesterUser];
    }
}

- (void)setActive:(BOOL)active toUser:(User *)theUser{
    
    theUser.isActive = active;
    
    for (int index= 0; index < self.acceptedOponentUsers.count; index++) {
        
        User *user = self.acceptedOponentUsers[index];
        
        if([user.deviceID isEqualToString:theUser.deviceID] && [user.deviceIP isEqualToString:theUser.deviceIP]){
            
            [self.acceptedOponentUsers replaceObjectAtIndex:index withObject:theUser];
        }
    }
}


- (void)removeOponetUserFromAcceptedList:(User *) requesterUser{
    
    for (int i= 0; i < self.acceptedOponentUsers.count; i++) {
        User *user = self.acceptedOponentUsers[i];
        if([user.deviceID isEqualToString:requesterUser.deviceID] && [user.deviceIP isEqualToString:requesterUser.deviceIP]){
            
            [self.acceptedOponentUsers removeObjectAtIndex:i];
        }
    }
    
    //[self.acceptedOponentUsers removeObject:requesterUser];
}

//-(BOOL)isHost{
//    return self.isHost;
//}

@end
