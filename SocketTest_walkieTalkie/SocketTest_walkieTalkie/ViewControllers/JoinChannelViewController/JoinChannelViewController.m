//
//  JoinChannelViewController.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/28/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "JoinChannelViewController.h"
#import "ChatViewController.h"

@interface JoinChannelViewController (){
    }
@property (weak, nonatomic) IBOutlet UITextField *client_Name_textField;
@property (weak, nonatomic) IBOutlet UITextField *channel_ID_TextField;

@end

@implementation JoinChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinChannelConfirmed:) name:JOINCHANNEL_CONFIRM_NOTIFICATIONKEY object:nil];
    UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
    [self.view addGestureRecognizer:aTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];


    // Do any additional setup after loading the view.
}

-(void)keyboardWasShown:(NSNotification*)notification
{
    CGFloat height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size.height;
    
    if (self.isViewLoaded && self.view.window) {
        // viewController is visible
        self.publicchannelACenterYConstraint.constant -= height;

    }
//    [self.view layoutSubviews];
}

-(void)viewWillAppear:(BOOL)animated{
    
//    self.title = @"Join Channel";
    self.client_Name_textField.text = [UIDevice currentDevice].name;
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0xE0362B);

}

-(void)viewWillDisappear:(BOOL)animated{
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

//    NSDictionary* userInfo = notification.userInfo;
//    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
//    NSLog (@"Successfully received foreign Channel Join Confirmed notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
//    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    
    
#warning For the love of God fix this
    
    //int channelID = [jsonDict objectForKey:JSON_KEY_CHANNEL];
    //Channel *personalChannel = [[ChannelManager sharedInstance] getChannel:channelID];
    //NSString *hostIP = personalChannel.hostUser.deviceIP;
    
    
//    NSArray *channelmembers  = [jsonDict objectForKey:JSON_KEY_CHANNEL_MEMBERS];
//    NSMutableArray *channelmemberIPs = [[NSMutableArray alloc] init];
//    NSMutableArray *channelmemberNames = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < channelmembers.count; i++) {
//        NSDictionary *channelMember = [channelmembers objectAtIndex:i];
//        [channelmemberIPs addObject:[channelMember objectForKey:JSON_KEY_IP_ADDRESS]];
//        [channelmemberNames addObject:[channelMember objectForKey:JSON_KEY_DEVICE_NAME]];
//    }
    

    
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
    
    NSString *channelJoinNotificationMessage = [[MessageHandler sharedHandler] joiningChannelMessageOf:channelID deviceName:self.client_Name_textField.text];
    
    
    if (type == kChannelTypePublic) {
        
        NSArray *currentAllUserIPs = [[UserHandler sharedInstance] getAllUserIPs];
        
        [[asyncUDPConnectionHandler sharedHandler] enableBroadCast];
        
        for (NSString *ipAddress in currentAllUserIPs) {
            
            [[asyncUDPConnectionHandler sharedHandler] sendMessage:channelJoinNotificationMessage toIPAddress:ipAddress];
        }
        
    }else if (type == kChannelTypePersonal) {
        
        Channel *personalChannel = [[ChannelManager sharedInstance] getChannel:channelID];
        NSString *hostIP = personalChannel.hostUser.deviceIP;
        
        [[asyncUDPConnectionHandler sharedHandler] sendMessage:channelJoinNotificationMessage toIPAddress:hostIP];
    }
}


- (IBAction)joinChannelTapped:(id)sender {
    

    int channelID = [self.channel_ID_TextField.text intValue];
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

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
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
