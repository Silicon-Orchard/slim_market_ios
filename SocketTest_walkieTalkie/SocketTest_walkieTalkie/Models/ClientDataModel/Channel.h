//
//  Channel.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Channel : NSObject

@property (nonatomic, assign) int channelID;
@property (nonatomic, assign) BOOL isHost;
@property (nonatomic, strong) User *hostUser;




#pragma mark - New Setup

-(id)initChannelWithID:(int)channelID;
-(id)initChannelWithID:(int)channelID andHost:(User *)host;

#pragma mark - Getter Method
- (NSArray *)getMembers;
- (NSArray *)getAllMemberIPs;
- (User *)getMemberWithIP:(NSString *)ip deviceID:(NSString* )deviceID;

#pragma mark - Setter Method
-(void)addMember:(User *)member;
-(void)addMemberWithIP:(NSString *)ip deviceID:(NSString* )deviceID name:(NSString*)name andActive:(BOOL)active;
-(void)removeMember:(User *)member;
-(void)removeMemberOfIP:(NSString *)ip andDeviceID:(NSString *)deviceID;

-(void) clearAll;

#pragma mark - Public Channel
- (BOOL)isPublicChannel;


#pragma mark - Private Channel
- (BOOL)isPrivateChannelWith:(User *) member;

- (BOOL)isAcceptedOponentUser:(User *) requesterUser;
- (void)addOponetUserToAcceptedList:(User *) requesterUser;
- (void)removeOponetUserFromAcceptedList:(User *) requesterUser;
- (void)setActive:(BOOL)active toUser:(User *)theUser;


#pragma mark - Personal Channel
- (BOOL)isPersonalChannel;

@end