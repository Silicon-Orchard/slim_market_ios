//
//  MessageData.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "MessageData.h"

@implementation MessageData


- (id)initWithSender:(NSString *)senderName  type:(int)type message:(NSString *)message progress:(NSProgress *)progress direction:(MessageDirection)direction {
    
    if (self = [super init]) {
        
        //_user = user;
        //_fileName = fileName;
        _progress = progress;
        _senderName = senderName;
        _type = type;
        _message = message;
        _direction = direction;
    }
    return self;
}

- (id)initWithSender:(NSString *)senderName  type:(int)type message:(NSString *)message direction:(MessageDirection)direction{
    
    return [self initWithSender:senderName type:type message:message progress:nil direction:direction];
}


//- (id)initWithSender:(NSString *)senderName type:(int)type message:(NSString *)message progress:(NSProgress *)progress direction:(MessageDirection)direction{
//    
//    return [self initWithSender:senderName type:type message:message progress:progress direction:direction];
//}

@end
