//
//  UserHandler.m
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 6/15/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "UserHandler.h"

@interface UserHandler ()

@property (nonatomic, strong) NSMutableArray *usersArray;
//@property (nonatomic, strong) NSMutableArray *userIPsArray;

@end

@implementation UserHandler

+ (UserHandler*)sharedInstance{
    
    static UserHandler *mySharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedInstance = [[UserHandler alloc] init];
        
    });
    
    return mySharedInstance;
}

- (instancetype)init {
    
    if(self = [super init]){
        // Do any other initialisation stuff here
        self.usersArray = [NSMutableArray new];
        //self.userIPsArray = [NSMutableArray new];
    }
    
    return  self;
}


- (NSArray *)getUsers {
    
    return self.usersArray;
}

- (NSArray *)getAllUserIPs {
    
    NSMutableArray *ipArray = [NSMutableArray new];
    
    for (User * user in self.usersArray) {
        
        [ipArray addObject:user.deviceIP];
    }
    
    return ipArray;
}

-(User *)getUserOfIndex:(NSUInteger)index {
    
    User * user = (User *)self.usersArray[index];
    
    return user;
}

-(void)addUser:(User *)user {
    
    if(![self isUserAlreadyInArrayOfIP:user.deviceIP andDeviceID:user.deviceID]){
        
        [self.usersArray addObject:user];
        //[self.userIPsArray addObject:user.deviceIP];
    }
}

-(void)addUserWithIP:(NSString *)ip deviceID:(NSString* )deviceID name:(NSString*)name andActive:(BOOL)active{
    
    
    if(![self isUserAlreadyInArrayOfIP:ip andDeviceID:deviceID]){
        
        User * user = [[User alloc] initWithIP:(NSString *)ip deviceID:(NSString* )deviceID name:(NSString*)name andActive:(BOOL)active];
        
        [self.usersArray addObject:user];
        //[self.userIPsArray addObject:user.deviceIP];
    }
}


-(void)removeUserofIP:(NSString *)ip andDeviceID:(NSString *)deviceID {
    
    for (User * user in self.usersArray) {
        
        if([user.deviceIP isEqualToString:ip] && [user.deviceID isEqualToString:deviceID] ){
            
            [self.usersArray removeObject:user];
            //[self.userIPsArray addObject:user.deviceIP];
        }
    }
}


#pragma mark - Private Helpers


-(BOOL)isUserAlreadyInArrayOfIP:(NSString *)ip andDeviceID:(NSString *)deviceID {
    
    for (User * user in self.usersArray) {
        
        if([user.deviceIP isEqualToString:ip] && [user.deviceID isEqualToString:deviceID] ){
            
            return YES;
        }
    }
    
    return NO;
}



@end
