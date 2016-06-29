//
//  ChannelManager.h
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 6/20/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChannelManager : NSObject

@property (nonatomic, strong) Channel *currentChannel;

@property (nonatomic, assign) int currentChannelID;
@property (nonatomic, assign) BOOL isHost;
@property (nonatomic, strong) User *hostUser;



#pragma mark - New Setup

+(ChannelManager*) sharedInstance;


-(Channel *)getChannel:(int)channelID;
-(void)saveChannel:(Channel *)channel;

-(void) clearAll;


#pragma mark - One to One

- (BOOL)isAcceptedOponentUser:(User *) requesterUser;
- (void)addOponetUserToAcceptedList:(User *) requesterUser;
- (void)removeOponetUserFromAcceptedList:(User *) requesterUser;
- (void)setActive:(BOOL)active toUser:(User *)theUser;

@end
