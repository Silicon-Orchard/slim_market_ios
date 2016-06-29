//
//  CreateChannelViewController.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/28/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "CreateChannelViewController.h"
#import "ChatViewController.h"

@interface CreateChannelViewController ()
@property (weak, nonatomic) IBOutlet UITextField *hostNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *channel_ID_TextField;

@end

@implementation CreateChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
    [self.view addGestureRecognizer:aTap];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
//    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0xE0362B);
//    self.title = @"Create Channel";
    self.hostNameTextField.text = [UIDevice currentDevice].name;

}

//UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
//[self.view addGestureRecognizer:aTap];

-(void)ScreenTapped{
    
    [self.view endEditing:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) createPersonalChannelWith:(int)channelID{
    
    User *mySelf = [UserHandler sharedInstance].mySelf;
    
    Channel *personalChannel = [[Channel alloc] initChannelWithID:channelID andHost:mySelf];
    personalChannel.isHost = YES;
    [[ChannelManager sharedInstance] saveChannel:personalChannel];
    [[ChannelManager sharedInstance] setCurrentChannel:personalChannel];
    
    
    NSString *channelCreatNotificationMessage = [[MessageHandler sharedHandler] newChannelCreatedMessageWithChannelID:channelID deviceName:self.hostNameTextField.text];
    NSArray * activeAllUserIPs = [[UserHandler sharedInstance] getAllUserIPs];
    
    [[asyncUDPConnectionHandler sharedHandler] enableBroadCast];
    
    
    for (NSString *ipAdrress in activeAllUserIPs) {
        
        [[asyncUDPConnectionHandler sharedHandler]sendMessage:channelCreatNotificationMessage toIPAddress:ipAdrress];
    }
    
    //[[asyncUDPConnectionHandler sharedHandler] disableBroadCast];
    
    [self performSegueWithIdentifier:@"hostChannelSegue" sender:nil];
}




//-(void)createChannelWithChannelID:(int)channelID{
//    
//    Channel *newChannel = [[Channel alloc] initWithChannelID:channelID];
//    newChannel.channelMemberIDs = [[NSMutableArray alloc] initWithObjects:[[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS], nil];
//    newChannel.channelMemberIPs = [[NSMutableArray alloc] initWithObjects:[[MessageHandler sharedHandler] getIPAddress], nil];
//    newChannel.channelMemberNamess = [[NSMutableArray alloc] initWithObjects:self.hostNameTextField.text, nil];
//    newChannel.foreignChannelHostDeviceID = [[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS];
//    newChannel.foreignChannelHostIP = [[MessageHandler sharedHandler] getIPAddress];
//    newChannel.foreignChannelHostName = self.hostNameTextField.text;
//
//
//    
//    [newChannel saveChannel:newChannel];
//    
//    NSString *channelCreatNotificationMessage = [[MessageHandler sharedHandler] newChannelCreatedMessageWithChannelID:channelID deviceName:self.hostNameTextField.text];
//    
//    [[asyncUDPConnectionHandler sharedHandler] enableBroadCast];
//    for (int i =1 ; i<=254; i++) {
//        [[asyncUDPConnectionHandler sharedHandler]sendMessage:channelCreatNotificationMessage toIPAddress:[NSString stringWithFormat:@"%@%d",[[NSUserDefaults standardUserDefaults] objectForKey:IPADDRESS_FORMATKEY],i]];
//    }
////    [[asyncUDPConnectionHandler sharedHandler] disableBroadCast];
//    [ChannelHandler sharedHandler].currentlyActiveChannelID = channelID;
//    [ChannelHandler sharedHandler].isHost = YES;
//    [ChannelHandler sharedHandler].userNameInChannel = self.hostNameTextField.text;
//    
//    [self performSegueWithIdentifier:@"hostChannelSegue" sender:nil];
//       
//}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    

    if ([segue.identifier isEqualToString:@"hostChannelSegue"]) {
        
        ChatViewController * chatVC = [segue destinationViewController];
        
        chatVC.currentActiveChannel = [[ChannelManager sharedInstance] currentChannel];
        chatVC.isPrivateChannel = NO;
        [UserHandler sharedInstance].mySelf.deviceName = self.hostNameTextField.text;
    }
}



- (IBAction)createChannelButtonTapped:(id)sender {
    
    [self createPersonalChannelWith:[self.channel_ID_TextField.text intValue]];

}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}


@end
