//
//  UserHandler.h
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 6/15/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserHandler : UIViewController

+ (UserHandler*) sharedInstance;

@property (nonatomic, strong) User *mySelf;


- (NSArray *)getUsers;
- (NSArray *)getAllUserIPs;
- (User *)getUserOfIndex:(NSUInteger)index;

-(void)addUser:(User *)user;
-(void)addUserWithIP:(NSString *)ip deviceID:(NSString* )deviceID name:(NSString*)name andActive:(BOOL)active;
-(void)removeUserofIP:(NSString *)ip andDeviceID:(NSString *)deviceID;


@end
