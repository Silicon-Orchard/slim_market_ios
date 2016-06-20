//
//  ChannelManager.h
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 6/20/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChannelManager : NSObject

+(UserHandler*) sharedInstance;


#pragma mark - New Setup

@property (nonatomic, assign) int channelID;
@property (nonatomic, assign) BOOL isHost;

//@property (nonatomic, strong) NSString * userNameInChannel;
//@property (nonatomic, strong) Channel *currentlyActiveChannel;
//-(void)initChannelWithID:(NSInteger)ID;
//-(void)initChannelWithID:(NSInteger)ID andHost:(User *)host;

- (NSArray *)getMembers;
- (NSArray *)getAllMemberIPs;

-(void)addMember:(User *)member;
-(void)addMemberWithIP:(NSString *)ip deviceID:(NSString* )deviceID name:(NSString*)name andActive:(BOOL)active;
-(void)removeMember:(User *)member;
-(void)removeMemberOfIP:(NSString *)ip andDeviceID:(NSString *)deviceID;

-(void) clearAll;


#pragma mark - Personal Chatting Code
- (BOOL)isAcceptedOponentUser:(User *) requesterUser;
- (void)addOponetUserToAcceptedList:(User *) requesterUser;
- (void)removeOponetUserFromAcceptedList:(User *) requesterUser;
- (void)setActive:(BOOL)active toUser:(User *)theUser;

@end
