//
//  ContactListVC.h
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 6/15/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactListVC : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
