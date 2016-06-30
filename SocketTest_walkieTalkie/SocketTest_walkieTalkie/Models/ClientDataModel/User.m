//
//  User.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "User.h"

@implementation User



-(instancetype)init {
    
    if(self = [super init]) {
        
    }
    
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary *)jsonDict {
    
    return [self initWithIP:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]
                   deviceID:[jsonDict objectForKey:JSON_KEY_DEVICE_ID]
                       name:[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]
                  andActive:NO];
}


-(instancetype)initWithDictionary:(NSDictionary *)jsonDict andActive:(BOOL)active{
    
    return [self initWithIP:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]
                   deviceID:[jsonDict objectForKey:JSON_KEY_DEVICE_ID]
                       name:[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]
                  andActive:active];
}


-(instancetype)initWithIP:(NSString *)ip deviceID:(NSString* )ID name:(NSString*)name andActive:(BOOL)active {
    
    if(self = [super init]) {
        
        self.deviceIP = ip;
        self.deviceID = ID;
        self.deviceName = name;
        self.isActive = active;
    }
    
    return self;
}






@end
