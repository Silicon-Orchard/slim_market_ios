//
//  User.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *deviceIP;
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, strong) NSString *deviceName;
@property BOOL isActive;


-(instancetype)initWithDictionary:(NSDictionary *)jsonDict;
-(instancetype)initWithDictionary:(NSDictionary *)jsonDict andActive:(BOOL)active;
-(instancetype)initWithIP:(NSString *)ip deviceID:(NSString* )ID name:(NSString*)name andActive:(BOOL)active;



@end
