//
//  Channel.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "Channel.h"

@interface Channel ()

@property (nonatomic, strong) NSMutableArray *memberList;
@end



@implementation Channel

#pragma mark - Initialisation

-(id)initChannelWithID:(int)channelID andHost:(User *)host{
    
    if ( self = [super init] ) {
        
        self.memberList = [NSMutableArray new];
        self.channelID = channelID;
        self.hostUser = host;
        
        if(channelID == kChannelIDPublicA || channelID == kChannelIDPublicB){
            self.isHost = NO;
        }
    }
    return self;
}

-(id)initChannelWithID:(int)channelID {
    
    return [self initChannelWithID:channelID andHost:nil];
}

#pragma mark - Getter Method

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

- (User *)getMemberWithIP:(NSString *)ip deviceID:(NSString* )deviceID{
    
    for (User * member in self.memberList) {
        
        if([member.deviceIP isEqualToString:ip] && [member.deviceID isEqualToString:deviceID] ){
            
            return member;
        }
    }
    
    return nil;
}

-(User *)getUserOfIndex:(NSUInteger)index {
    
    User * user = (User *)self.memberList[index];
    return user;
}

#pragma mark - Setter Method

-(void)addMember:(User *)member {
    
    if(![self isMemberAlreadyInListOfIP:member.deviceIP andDeviceID:member.deviceID]){
        
        [self.memberList addObject:member];
    }else{
        
        [self updateMember:member];
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
    self.hostUser = nil;
}


#pragma mark - Private method


-(BOOL)isMemberAlreadyInListOfIP:(NSString *)ip andDeviceID:(NSString *)deviceID {
    
    for (User * member in self.memberList) {
        
        if([member.deviceIP isEqualToString:ip] && [member.deviceID isEqualToString:deviceID] ){
            
            return YES;
        }
    }
    
    return NO;
}

-(void)updateMember:(User *)theMember{
    
    for (int i = 0; i< self.memberList.count; i++) {
        User *aMember = self.memberList[i];
        
        if([aMember.deviceIP isEqualToString:theMember.deviceIP] && [aMember.deviceID isEqualToString:theMember.deviceIP] ){
            
            [self.memberList replaceObjectAtIndex:i withObject:theMember];
        }
    }
}


#pragma mark - Public Channel
- (BOOL)isPublicChannel{
    
    if(self.channelID == kChannelIDPublicA || self.channelID == kChannelIDPublicB){
        
        return YES;
    }
    
    return NO;
}



#pragma mark - Private Channel

- (BOOL)isPrivateChannelWith:(User *) member{
    
    if(self.channelID == kChannelIDPersonal && self.memberList.count == 1){
        
        User *oponentUser = self.memberList[0];
        
        if(member.deviceID == oponentUser.deviceID && member.deviceIP == oponentUser.deviceIP){
            return YES;
        }
    }
    
    return NO;
}

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


#pragma mark - Personal Channel

- (BOOL)isPersonalChannel{
    
    if( !(self.channelID == kChannelIDPublicA || self.channelID == kChannelIDPublicB) ){
        
        if([ChannelManager sharedInstance].hostUser){
            
            return YES;
        }
    }
    
    return NO;
}




@end

