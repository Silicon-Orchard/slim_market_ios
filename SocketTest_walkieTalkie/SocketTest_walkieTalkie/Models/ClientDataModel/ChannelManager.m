//
//  ChannelManager.m
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 6/20/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "ChannelManager.h"

@interface ChannelManager ()

@property (nonatomic, strong) NSMutableArray *memberList;
//@property (nonatomic, strong) NSMutableArray * acceptedOponentUsers;

@end

@implementation ChannelManager


+ (ChannelManager*)sharedInstance{
    
    static ChannelManager *mySharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedInstance = [[ChannelManager alloc] init];
        
    });
    
    return mySharedInstance;
}

- (instancetype)init {
    
    if(self = [super init]){
        // Do any other initialisation stuff here
        self.memberList = [NSMutableArray new];

    }
    
    return  self;
}





- (NSArray *)getMembers {
    
    return self.memberList;
}

- (NSArray *)getAllMemberIPs {
    
    NSMutableArray *ipArray = [NSMutableArray new];
    
    for (User * user in self.memberList) {
        
        [ipArray addObject:user.deviceIP];
    }
    
    return ipArray;
}

-(User *)getUserOfIndex:(NSUInteger)index {
    
    User * user = (User *)self.memberList[index];
    return user;
}

-(void)addMember:(User *)member {
    
    if(![self isMemberAlreadyInListOfIP:member.deviceIP andDeviceID:member.deviceID]){
        
        [self.memberList addObject:member];
    }
}

-(void)addMemberWithIP:(NSString *)ip deviceID:(NSString* )deviceID name:(NSString*)name andActive:(BOOL)active{
    
    
    if(![self isMemberAlreadyInListOfIP:ip andDeviceID:deviceID]){
        
        User * member = [[User alloc] initWithIP:(NSString *)ip deviceID:(NSString* )deviceID name:(NSString*)name andActive:(BOOL)active];
        [self.memberList addObject:member];
    }
}


-(void)removeMember:(User *)member {
    
    [self removeMemberOfIP:member.deviceIP andDeviceID:member.deviceID];
}

-(void)removeMemberOfIP:(NSString *)ip andDeviceID:(NSString *)deviceID {
    
    for (User * member in self.memberList) {
        
        if([member.deviceIP isEqualToString:ip] && [member.deviceID isEqualToString:deviceID] ){
            
            [self.memberList removeObject:member];
        }
    }
}

- (void)clearAll {
    
    [self.memberList removeAllObjects];
    
    self.channelID = 0;
    self.isHost = NO;
}


#pragma mark - Private Helpers


-(BOOL)isMemberAlreadyInListOfIP:(NSString *)ip andDeviceID:(NSString *)deviceID {
    
    for (User * member in self.memberList) {
        
        if([member.deviceIP isEqualToString:ip] && [member.deviceID isEqualToString:deviceID] ){
            
            return YES;
        }
    }
    
    return NO;
}









#pragma mark - Personal Chatting Code

- (BOOL)isAcceptedOponentUser:(User *) requesterUser {
    
    for (User *user in self.memberList) {
        
        if([user.deviceID isEqualToString:requesterUser.deviceID] && [user.deviceIP isEqualToString:requesterUser.deviceIP]){
            
            return YES;
        }
    }
    
    return NO;
}

- (void)addOponetUserToAcceptedList:(User *) requesterUser{
    
    if(![self isAcceptedOponentUser:requesterUser]){
        
        [self.memberList addObject:requesterUser];
    }
}

- (void)setActive:(BOOL)active toUser:(User *)theUser{
    
    theUser.isActive = active;
    
    for (int index= 0; index < self.memberList.count; index++) {
        
        User *user = self.memberList[index];
        
        if([user.deviceID isEqualToString:theUser.deviceID] && [user.deviceIP isEqualToString:theUser.deviceIP]){
            
            [self.memberList replaceObjectAtIndex:index withObject:theUser];
        }
    }
}


- (void)removeOponetUserFromAcceptedList:(User *) requesterUser{
    
    for (int i= 0; i < self.memberList.count; i++) {
        User *user = self.memberList[i];
        if([user.deviceID isEqualToString:requesterUser.deviceID] && [user.deviceIP isEqualToString:requesterUser.deviceIP]){
            
            [self.memberList removeObjectAtIndex:i];
        }
    }
}





@end
