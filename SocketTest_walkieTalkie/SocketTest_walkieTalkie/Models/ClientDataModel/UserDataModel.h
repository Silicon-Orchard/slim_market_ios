//
//  UserDataModel.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDataModel : NSObject

@property (nonatomic, strong) NSString *deviceIPAddress;
@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) int messageTYPE;
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, strong) NSString *clientIP;
@property (nonatomic, assign) uint16_t clientPort;
@property (nonatomic, assign) int channelID;


@end
