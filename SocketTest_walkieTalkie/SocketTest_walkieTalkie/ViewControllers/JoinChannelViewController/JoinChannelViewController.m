//
//  JoinChannelViewController.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/28/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "JoinChannelViewController.h"
#import "ChatViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface JoinChannelViewController (){
    
    int requestedChannelID;
    
    UITextField * activeField;
}
@property (weak, nonatomic) IBOutlet UITextField *client_Name_textField;
@property (weak, nonatomic) IBOutlet UITextField *channel_ID_TextField;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation JoinChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinChannelConfirmed:) name:JOINCHANNEL_CONFIRM_NOTIFICATIONKEY object:nil];
    UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
    [self.view addGestureRecognizer:aTap];
    
    
    // Do any additional setup after loading the view.
    [self configUI];
    [self registerForKeyboardNotifications];
    
}
-(void)configUI{
    
    self.client_Name_textField.layer.borderColor = [[UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:1.0] CGColor];
    self.client_Name_textField.layer.borderWidth = 1.0;
    self.client_Name_textField.layer.cornerRadius = 5;
    
    //    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Some Text" attributes:@{ NSForegroundColorAttributeName : [UIColor redColor] }];
    //    self.hostNameTextField.attributedPlaceholder = str;
    
    
    self.channel_ID_TextField.layer.borderColor = [[UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:1.0] CGColor];
    self.channel_ID_TextField.layer.borderWidth = 1.0;
    self.channel_ID_TextField.layer.cornerRadius = 5;
    
    
    self.btnAView.layer.borderColor = [[UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:1.0] CGColor];
    self.btnAView.layer.borderWidth = 1.0f;
    self.btnAView.layer.cornerRadius = 5;
    
    self.btnBView.layer.borderColor = [[UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:1.0] CGColor];
    self.btnBView.layer.borderWidth = 1.0f;
    self.btnBView.layer.cornerRadius = 5;
    
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


#pragma mark - TextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    activeField = textField;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}




-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.title = @"Join Channel";

    
    self.client_Name_textField.text = [UIDevice currentDevice].name;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.title = @"Back";
    
    self.publicchannelACenterYConstraint.constant = 0;
    [self.view layoutIfNeeded];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)ScreenTapped{
    [self.view endEditing:YES];
    self.publicchannelACenterYConstraint.constant = 0;

}

-(void) joinChannelConfirmed:(NSNotification*)notification{
    
    NSLog(@"joinCHannelConfirmed");

    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    
    
    int channelID = [[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue];
    Channel *personalChannel = [[ChannelManager sharedInstance] getChannel:channelID];
    
    if(requestedChannelID == channelID && personalChannel){
        //Personal Channel
        
//        User *hostMember = [[User alloc] initWithIP:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]
//                                         deviceID:[jsonDict objectForKey:JSON_KEY_DEVICE_ID]
//                                             name:[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]
//                                        andActive:YES];
        
        personalChannel.hostUser.isActive = YES;
        [personalChannel addMember:personalChannel.hostUser];
        
        NSArray *channelMembers  = [jsonDict objectForKey:JSON_KEY_CHANNEL_MEMBERS];
        
        User *mySlefMember = [UserHandler sharedInstance].mySelf;
        for (NSDictionary *channelMember in channelMembers) {
            
            NSString *memberIP = [channelMember objectForKey:JSON_KEY_IP_ADDRESS];
            NSString *memberID = [channelMember objectForKey:JSON_KEY_DEVICE_ID];
            NSString *memberName = [channelMember objectForKey:JSON_KEY_DEVICE_NAME];
            
            if( !([mySlefMember.deviceIP isEqualToString:memberIP] && [mySlefMember.deviceID isEqualToString:memberID]) ){
                
                User * aMember = [[User alloc] initWithIP:memberIP
                                                 deviceID:memberID
                                                     name:memberName
                                                andActive:YES];
                
                [personalChannel addMember:aMember];
            }

        }
        
        // Go to the personal channel
        [[ChannelManager sharedInstance] setCurrentChannel:personalChannel];
        
#warning close HUD
        [self performSegueWithIdentifier:@"clientChannelSegue" sender:nil];
        
        
    } else {
        
    }
    
    
    
    //NSString *hostIP = personalChannel.hostUser.deviceIP;
    
    

    

    
//    joinedChannel.channelMemberIPs = channelmemberIPs;
//    joinedChannel.channelMemberNamess = channelmemberNames;
//    
//    [joinedChannel replaceForeignChannelOfID:[[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] withChannel:joinedChannel];
//    
//    
//    NSLog(@"JOined channel");
//    
//    if (!self.isChatOpen) {
//        [ChannelHandler sharedHandler].currentlyActiveChannelID = [[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue];
//        [ChannelHandler sharedHandler].isHost = NO;
//        for (int i = 0; i<joinedChannel.channelMemberIPs.count; i++) {
//            if ([[joinedChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
//                [ChannelHandler sharedHandler].userNameInChannel = [joinedChannel.channelMemberNamess objectAtIndex:i];
//            }
//        }
//        
//        [self performSegueWithIdentifier:@"clientChannelSegue" sender:nil];
//        self.isChatOpen = YES;
//        
//    } else{
//        if (joinedChannel.channelID == [ChannelHandler sharedHandler].currentlyActiveChannelID) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentChannelUpdated" object:nil userInfo:nil];
//            
//        }
//    }
    
    
//
//
//    if (joinedChannel) {
//        if ([[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] ==1 || [[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] ==2) {
//           
//            [joinedChannel.channelMemberIPs addObject:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]];
//            [joinedChannel.channelMemberNamess addObject:[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]];
//            [joinedChannel replaceForeignChannelOfID:[[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] withChannel:joinedChannel];
//
//            
//        }
//        else{
//            NSArray *channelmembers  = [jsonDict objectForKey:JSON_KEY_CHANNEL_MEMBERS];
//            NSMutableArray *channelmemberIPs = [[NSMutableArray alloc] init];
//            NSMutableArray *channelmemberNames = [[NSMutableArray alloc] init];
//            
//            for (int i = 0; i < channelmembers.count; i++) {
//                NSDictionary *channelMember = [channelmembers objectAtIndex:i];
//                [channelmemberIPs addObject:[channelMember objectForKey:JSON_KEY_IP_ADDRESS]];
//                [channelmemberNames addObject:[channelMember objectForKey:JSON_KEY_DEVICE_NAME]];
//            }
//            
//            joinedChannel.channelMemberIPs = channelmemberIPs;
//            joinedChannel.channelMemberNamess = channelmemberNames;
//            
//            [joinedChannel replaceForeignChannelOfID:[[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] withChannel:joinedChannel];
//            
//            
//            NSLog(@"JOined channel");
//        
//        }
//
//        
//        
//
//    }
//    else{
//        joinedChannel = [[Channel alloc] initWithChannelID:[[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue]];
//        NSArray *channelmembers  = [jsonDict objectForKey:JSON_KEY_CHANNEL_MEMBERS];
//        NSMutableArray *channelmemberIPs = [[NSMutableArray alloc] initWithCapacity:channelmembers.count];
//        NSMutableArray *channelmemberNames = [[NSMutableArray alloc] initWithCapacity:channelmembers.count];
//        
//        for (int i = 0; i < channelmembers.count; i++) {
//            NSDictionary *channelMember = [channelmembers objectAtIndex:i];
//            [channelmemberIPs addObject:[channelMember objectForKey:JSON_KEY_IP_ADDRESS]];
//            [channelmemberNames addObject:[channelMember objectForKey:JSON_KEY_DEVICE_NAME]];
//        }
//        if ([[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] ==1 || [[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] ==2) {
//            [channelmemberIPs addObject:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]];
//            [channelmemberNames addObject:[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]];
//        }
//        
//        joinedChannel.channelMemberIPs = channelmemberIPs;
//        joinedChannel.channelMemberNamess = channelmemberNames;
//        joinedChannel.foreignChannelHostIP = [joinedChannel.channelMemberIPs objectAtIndex:0];
//        joinedChannel.foreignChannelHostName = [joinedChannel.channelMemberNamess objectAtIndex:0];
//        [blankChannel saveForeignChannel:joinedChannel];
//    }
//    
//    
//    if (!self.isChatOpen) {
//        [ChannelHandler sharedHandler].currentlyActiveChannelID = [[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue];
//        [ChannelHandler sharedHandler].isHost = NO;
//        for (int i = 0; i<joinedChannel.channelMemberIPs.count; i++) {
//            if ([[joinedChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
//                [ChannelHandler sharedHandler].userNameInChannel = [joinedChannel.channelMemberNamess objectAtIndex:i];
//            }
//        }
//
//         [self performSegueWithIdentifier:@"clientChannelSegue" sender:nil];
//        self.isChatOpen = YES;
//        
//    } else{
//        if (joinedChannel.channelID == [ChannelHandler sharedHandler].currentlyActiveChannelID) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentChannelUpdated" object:nil userInfo:nil];
//
//        }
//    }
//


}



-(void)sendJoiningChannelMessageOf:(int)channelID ofType:(int)type{
    
#warning show HUD
    
    
    
    NSString *channelJoinNotificationMessage = [[MessageHandler sharedHandler] joiningChannelMessageOf:channelID deviceName:self.client_Name_textField.text];
    
    [[asyncUDPConnectionHandler sharedHandler] enableBroadCast];
    
    if (type == kChannelTypePublic) {
        
        NSArray *currentAllUserIPs = [[UserHandler sharedInstance] getAllUserIPs];
        
        for (NSString *ipAddress in currentAllUserIPs) {
            
            [[asyncUDPConnectionHandler sharedHandler] sendMessage:channelJoinNotificationMessage toIPAddress:ipAddress];
        }
        
    }else if (type == kChannelTypePersonal) {
        
        Channel *personalChannel = [[ChannelManager sharedInstance] getChannel:channelID];
        
        if(personalChannel){
            
            NSString *hostIP = personalChannel.hostUser.deviceIP;
            [[asyncUDPConnectionHandler sharedHandler] sendMessage:channelJoinNotificationMessage toIPAddress:hostIP];
        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Not Found"
                                                            message: @"Sorry, the requested channel not found. Please check the channel number and try again."
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        

    }
}


- (IBAction)joinChannelTapped:(id)sender {
    

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
    
    requestedChannelID = channelID;
    [self sendJoiningChannelMessageOf:channelID ofType:kChannelTypePersonal];
}

- (IBAction)joinPublicChannelA:(id)sender {
    
    
    Channel *publicChannelA = [[Channel alloc] initChannelWithID:kChannelIDPublicA];
    [[ChannelManager sharedInstance] setCurrentChannel:publicChannelA];
    
    [self sendJoiningChannelMessageOf:kChannelIDPublicA ofType:kChannelTypePublic];

    
    self.isChatOpen = YES;
    [self performSegueWithIdentifier:@"clientChannelSegue" sender:nil];
}

- (IBAction)joinPublicChannelB:(id)sender {
    
    Channel *publicChannelB = [[Channel alloc] initChannelWithID:kChannelIDPublicB];
    [[ChannelManager sharedInstance] setCurrentChannel:publicChannelB];
    
    [self sendJoiningChannelMessageOf:kChannelIDPublicB ofType:kChannelTypePublic];
    
    self.isChatOpen = YES;
    [self performSegueWithIdentifier:@"clientChannelSegue" sender:nil];
}


#pragma mark _ Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    
    if ([segue.identifier isEqualToString:@"clientChannelSegue"]) {
        
        ChatViewController *chatVC = [segue destinationViewController];
        
        chatVC.currentActiveChannel = [[ChannelManager sharedInstance] currentChannel];
        chatVC.isPrivateChannel = NO;
        
        [UserHandler sharedInstance].mySelf.deviceName = self.client_Name_textField.text;
    }
}

@end
