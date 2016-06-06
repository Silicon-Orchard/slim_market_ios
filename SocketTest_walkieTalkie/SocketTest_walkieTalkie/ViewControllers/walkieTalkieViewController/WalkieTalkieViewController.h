//
//  WalkieTalkieViewController.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>


@interface WalkieTalkieViewController : UIViewController <GCDAsyncUdpSocketDelegate, UITextFieldDelegate>

@end
