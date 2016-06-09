//
//  IncomingMessageCell.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 6/8/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "IncomingMessageCell.h"

@implementation IncomingMessageCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
    self.nameLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.nameLabel.frame);
}

@end
