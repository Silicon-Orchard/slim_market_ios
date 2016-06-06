//
//  ViewController.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/26/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

@interface ViewController : UIViewController <GCDAsyncUdpSocketDelegate, UITextFieldDelegate>


@end

