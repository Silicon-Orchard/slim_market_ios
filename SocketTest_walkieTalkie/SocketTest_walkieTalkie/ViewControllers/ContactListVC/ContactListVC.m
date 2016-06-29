//
//  ContactListVC.m
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 6/15/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "ContactListVC.h"
#import "ContactListTVC.h"
#import "ChatViewController.h"

@interface ContactListVC ()

@property (nonatomic, strong) NSArray * contactListArrays;
@property (nonatomic, strong) User *selectedUser;

@end

@implementation ContactListVC 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.contactListArrays = [NSArray arrayWithArray:[[UserHandler sharedInstance] getUsers]];

    
    //self.navigationItem setting
    self.title = @"Contact List";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0xE0362B);
    
    //TableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0.2f]];
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewDeviceToNetWorkDeviceList:) name:NEW_DEVICE_CONNECTED_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLeftSystem:) name:USER_LEFT_SYSTEM_NOTIFICATIONKEY object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0xE0362B);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_DEVICE_CONNECTED_NOTIFICATIONKEY object:nil];
}

#pragma mark - NSNotification

- (void)addNewDeviceToNetWorkDeviceList:(NSNotification *) sender {
    
    self.contactListArrays = [[UserHandler sharedInstance] getUsers];
    
    [self.tableView reloadData];

}

- (void)userLeftSystem:(NSNotification *) sender {
    
    self.contactListArrays = [[UserHandler sharedInstance] getUsers];
    
    [self.tableView reloadData];
}




#pragma mark - UITableViewDataSource

static NSString * CellID = @"ContactListCellID";

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.contactListArrays.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    User * user = [self.contactListArrays objectAtIndex:indexPath.row];
    
    ContactListTVC *cell =  (ContactListTVC *)[tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    cell.userName.text = user.deviceName;
    //cell.backgroundColor = [UIColor clearColor];
    
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    return [UIView new];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedUser = [self.contactListArrays objectAtIndex:indexPath.row];
    self.selectedUser.isActive = NO;
    
    if(self.selectedUser){
        
        //send a Request to User
        NSString * message = [[MessageHandler sharedHandler] oneToOneChatRequestMessage];
        [[asyncUDPConnectionHandler sharedHandler] sendMessage:message toIPAddress:self.selectedUser.deviceIP];
        
        //add to accepted list
        [[ChannelManager sharedInstance] addOponetUserToAcceptedList:self.selectedUser];
        
        [self performSegueWithIdentifier:@"PersonalChannelSegue" sender:nil];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"PersonalChannelSegue"]) {
        
        
        ChatViewController * chatViewController = [segue destinationViewController];
        
        Channel *privateChannel = [[Channel alloc] initChannelWithID:kChannelIDPersonal];
        [privateChannel addMember: self.selectedUser];
        
        chatViewController.isPrivateChannel = YES;
        chatViewController.oponentUser = self.selectedUser;
        chatViewController.currentActiveChannel = privateChannel;
        [[ChannelManager sharedInstance] setCurrentChannel:privateChannel];
    }
}


@end
