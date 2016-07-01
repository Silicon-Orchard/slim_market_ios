//
//  CreateChannelViewController.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/28/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "CreateChannelViewController.h"
#import "ChatViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CreateChannelViewController (){
    
    UITextField * selectedTextField;
    CGFloat storedHeight;
    BOOL heightChanged;

}
@property (weak, nonatomic) IBOutlet UITextField *hostNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *channel_ID_TextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintChannelNum;

//@property (weak, nonatomic) NSLayoutConstraint *bottomConstraintChannelNum;

@end

@implementation CreateChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
    [self.view addGestureRecognizer:aTap];

    // Do any additional setup after loading the view.
    storedHeight = 0.0f;

    self.hostNameTextField.text = [UIDevice currentDevice].name;
    
    [self configUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHide:) name:UIKeyboardDidHideNotification object:nil];
}

-(void)configUI{
    
    self.hostNameTextField.layer.borderColor = [[UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:1.0] CGColor];
    self.hostNameTextField.layer.borderWidth = 1.0;
    self.hostNameTextField.layer.cornerRadius = 5;
    
//    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Some Text" attributes:@{ NSForegroundColorAttributeName : [UIColor redColor] }];
//    self.hostNameTextField.attributedPlaceholder = str;
    
    
    self.channel_ID_TextField.layer.borderColor = [[UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:1.0] CGColor];
    self.channel_ID_TextField.layer.borderWidth = 1.0;
    self.channel_ID_TextField.layer.cornerRadius = 5;
}

-(void)viewWillAppear:(BOOL)animated{
//  self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [super viewWillAppear:animated];
    
    self.title = @"Create Channel";
}

-(void) viewWillDisappear:(BOOL)animated{
    
    self.title = @"Back";
    
    [super viewWillDisappear:animated];
}

//UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
//[self.view addGestureRecognizer:aTap];

-(void)ScreenTapped{
    
    [self.view endEditing:YES];
    
}

-(void)keyboardWasShown:(NSNotification*)notification {
    
    CGFloat height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size.height;
    
    
    CGFloat bottomHeight = selectedTextField.superview.frame.size.height - (selectedTextField.frame.origin.y + selectedTextField.frame.size.height);
    
    if(bottomHeight < height){
        
        storedHeight = self.bottomConstraintChannelNum.constant;
        self.bottomConstraintChannelNum.constant = height + 10;
        [self.view layoutIfNeeded];
        heightChanged = true;
    }
    
    
}

-(void)keyboardWasHide:(NSNotification*)notification {
    
    CGFloat height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size.height;
    
    if(self.bottomConstraintChannelNum.constant == height + 10 && storedHeight != 0.0f){
        
        //storedHeight = self.bottomConstraintChannelNum.constant;
        self.bottomConstraintChannelNum.constant = storedHeight;
        [self.view layoutIfNeeded];
    }
    
    storedHeight = 0.0f;
    heightChanged = false;
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
    
    int channelID = [self.channel_ID_TextField.text intValue];
    
    int digitNumber = floor (log10 (abs (channelID))) + 1;
    
    if(digitNumber != 4){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Enter four digit channel number"
                                                        message: @""
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    Channel *channel = [[ChannelManager sharedInstance] getChannel:channelID];
    
    if(channel){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Already Exists!!!"
                                                        message: @"Channel number already exists. Please Choose different channel number."
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    [self createPersonalChannelWith:channelID];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    selectedTextField = textField;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}


@end
