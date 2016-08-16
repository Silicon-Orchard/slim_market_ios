//
//  IPChangeNotifier.h
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 6/28/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol IPChangeNotifierDelegate;

@interface IPChangeNotifier : NSObject {
    NSString *prevIP;
    NSTimer *changeTimer;
    id changeDelegate;
}

+(NSString*)getIPAddress;

-(id) initWithTimer:(float)time andDelegate:(id)del;
-(void) checkForChange;

@end

@protocol IPChangeNotifierDelegate <NSObject>
@optional
-(void) IPChangeDetected:(NSString*)newIP previousIP:(NSString*)oldIP;
@end