//
//  JoinChannelViewController.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/28/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JoinChannelViewController : UIViewController <UITextFieldDelegate>

@property(nonatomic, assign) BOOL isChatOpen;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *publicchannelACenterYConstraint;


@end
