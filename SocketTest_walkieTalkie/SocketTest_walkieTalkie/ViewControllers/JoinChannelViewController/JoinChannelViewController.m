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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinCHannelConfirmed:) name:JOINCHANNEL_CONFIRM_NOTIFICATIONKEY object:nil];
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

-(void) joinCHannelConfirmed:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSLog (@"Successfully received foreign Channel Join Confirmed notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    Channel *blankChannel = [[Channel alloc] init];
    Channel *joinedChannel = [blankChannel getForeignChannel:[[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue]];
    if (joinedChannel) {
        if ([[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] ==1 || [[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] ==2) {
           
            [joinedChannel.channelMemberIPs addObject:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]];
            [joinedChannel.channelMemberNamess addObject:[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]];
            [joinedChannel replaceForeignChannelOfID:[[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] withChannel:joinedChannel];

            
        }
        else{
            NSArray *channelmembers  = [jsonDict objectForKey:JSON_KEY_CHANNEL_MEMBERS];
            NSMutableArray *channelmemberIPs = [[NSMutableArray alloc] init];
            NSMutableArray *channelmemberNames = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < channelmembers.count; i++) {
                NSDictionary *channelMember = [channelmembers objectAtIndex:i];
                [channelmemberIPs addObject:[channelMember objectForKey:JSON_KEY_IP_ADDRESS]];
                [channelmemberNames addObject:[channelMember objectForKey:JSON_KEY_DEVICE_NAME]];
            }
            
            joinedChannel.channelMemberIPs = channelmemberIPs;
            joinedChannel.channelMemberNamess = channelmemberNames;
            
            [joinedChannel replaceForeignChannelOfID:[[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] withChannel:joinedChannel];
            
            
            NSLog(@"JOined channel");
        
        }

        
        

    }
    else{
        joinedChannel = [[Channel alloc] initWithChannelID:[[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue]];
        NSArray *channelmembers  = [jsonDict objectForKey:JSON_KEY_CHANNEL_MEMBERS];
        NSMutableArray *channelmemberIPs = [[NSMutableArray alloc] initWithCapacity:channelmembers.count];
        NSMutableArray *channelmemberNames = [[NSMutableArray alloc] initWithCapacity:channelmembers.count];
        
        for (int i = 0; i < channelmembers.count; i++) {
            NSDictionary *channelMember = [channelmembers objectAtIndex:i];
            [channelmemberIPs addObject:[channelMember objectForKey:JSON_KEY_IP_ADDRESS]];
            [channelmemberNames addObject:[channelMember objectForKey:JSON_KEY_DEVICE_NAME]];
        }
        if ([[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] ==1 || [[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue] ==2) {
            [channelmemberIPs addObject:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]];
            [channelmemberNames addObject:[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]];
        }
        
        joinedChannel.channelMemberIPs = channelmemberIPs;
        joinedChannel.channelMemberNamess = channelmemberNames;
        joinedChannel.foreignChannelHostIP = [joinedChannel.channelMemberIPs objectAtIndex:0];
        joinedChannel.foreignChannelHostName = [joinedChannel.channelMemberNamess objectAtIndex:0];
        [blankChannel saveForeignChannel:joinedChannel];
    }
    
    
    if (!self.isChatOpen) {
        [ChannelHandler sharedHandler].currentlyActiveChannelID = [[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue];
        [ChannelHandler sharedHandler].isHost = NO;
        for (int i = 0; i<joinedChannel.channelMemberIPs.count; i++) {
            if ([[joinedChannel.channelMemberIPs objectAtIndex:i] isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
                [ChannelHandler sharedHandler].userNameInChannel = [joinedChannel.channelMemberNamess objectAtIndex:i];
            }
        }
//        [ChannelHandler sharedHandler].userNameInChannel = [jsonDict objectForKey:JSON_KEY_DEVICE_NAME];

         [self performSegueWithIdentifier:@"clientChannelSegue" sender:nil];
        self.isChatOpen = YES;
    }
    else{
        if (joinedChannel.channelID == [ChannelHandler sharedHandler].currentlyActiveChannelID) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"currentChannelUpdated" object:nil userInfo:nil];

        }
    }
   

    
}


-(void)startHostChannelChatForChannelData:(NSData *)channelData{

    

}

-(void)joinChannelWithChannelID:(int)channelID{
    
    Channel *newChannel = [[Channel alloc] init];
    
    Channel *foreignChannel = [newChannel getForeignChannel:channelID];
    NSString *channelJoinNotificationMessage = [[MessageHandler sharedHandler] joinChannelCreatedMessageWithChannelID:channelID deviceName:self.client_Name_textField.text];
    
    NSString *foreignChannelOwnerIPaddress;
    
    NSArray *activeIPAddressList = [[NSUserDefaults standardUserDefaults] objectForKey:ACTIVEUSERLISTKEY];
    if (foreignChannel) {
        foreignChannelOwnerIPaddress = foreignChannel.foreignChannelHostIP;
        if (foreignChannel.channelID ==1 || foreignChannel.channelID ==2) {
            [[asyncUDPConnectionHandler sharedHandler] enableBroadCast];
            
            for (int i =0 ; i<activeIPAddressList.count; i++) {
                NSString *ipAddressTosendData = [activeIPAddressList objectAtIndex:i];
                if (![ipAddressTosendData isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
                    [[asyncUDPConnectionHandler sharedHandler]sendMessage:channelJoinNotificationMessage toIPAddress:ipAddressTosendData];
                }
                
            }
        }
        else{
             [[asyncUDPConnectionHandler sharedHandler]sendMessage:channelJoinNotificationMessage toIPAddress:foreignChannelOwnerIPaddress];
        }
       

    }
    else{
        [[asyncUDPConnectionHandler sharedHandler] enableBroadCast];
        
        for (int i =0 ; i<activeIPAddressList.count; i++) {
            NSString *ipAddressTosendData = [activeIPAddressList objectAtIndex:i];
            if (![ipAddressTosendData isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
                [[asyncUDPConnectionHandler sharedHandler]sendMessage:channelJoinNotificationMessage toIPAddress:ipAddressTosendData];
            }
            
        }
        
    }

    
}


- (IBAction)joinChannelTapped:(id)sender {
    [self joinChannelWithChannelID:[self.channel_ID_TextField.text intValue]];
}

- (IBAction)joinPublicChannelA:(id)sender {
    
    [ChannelHandler sharedHandler].currentlyActiveChannelID = 1;
    [ChannelHandler sharedHandler].isHost = NO;
    [ChannelHandler sharedHandler].userNameInChannel = self.client_Name_textField.text;
    
    [self joinChannelWithChannelID:1];
    Channel *publicChannelA = [[Channel alloc] initWithChannelID:1];
    NSMutableArray *channelmemberIPs = [[NSMutableArray alloc] init];
    NSMutableArray *channelmemberNames = [[NSMutableArray alloc] init];

    [channelmemberIPs addObject:[[MessageHandler sharedHandler] getIPAddress]];
    [channelmemberNames addObject:self.client_Name_textField.text];
    publicChannelA.channelMemberNamess = channelmemberNames;
    publicChannelA.channelMemberIPs = channelmemberIPs;
    [publicChannelA saveChannel:publicChannelA];
    [publicChannelA replaceForeignChannelOfID:1 withChannel:publicChannelA];


    self.isChatOpen = YES;
    [self performSegueWithIdentifier:@"clientChannelSegue" sender:nil];
    
    
}
- (IBAction)joinPublicChannelB:(id)sender {
    
    [ChannelHandler sharedHandler].currentlyActiveChannelID = 2;
    [ChannelHandler sharedHandler].isHost = NO;
    [ChannelHandler sharedHandler].userNameInChannel = self.client_Name_textField.text;
    [self joinChannelWithChannelID:2];
    Channel *publicChannelB = [[Channel alloc] initWithChannelID:2];
    NSMutableArray *channelmemberIPs = [[NSMutableArray alloc] init];
    NSMutableArray *channelmemberNames = [[NSMutableArray alloc] init];
    
    [channelmemberIPs addObject:[[MessageHandler sharedHandler] getIPAddress]];
    [channelmemberNames addObject:self.client_Name_textField.text];
    publicChannelB.channelMemberNamess = channelmemberNames;
    publicChannelB.channelMemberIPs = channelmemberIPs;
    [publicChannelB saveChannel:publicChannelB];
    [publicChannelB replaceForeignChannelOfID:2 withChannel:publicChannelB];

    self.isChatOpen = YES;

    [self performSegueWithIdentifier:@"clientChannelSegue" sender:nil];
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"clientChannelSegue"]) {
        
        Channel *blank = [[Channel alloc] init];
        ChatViewController * chatControl = [segue destinationViewController];
        Channel *currentChannelForeign = [blank getForeignChannel: [ChannelHandler sharedHandler].currentlyActiveChannelID];
        chatControl.currentActiveChannel = currentChannelForeign;
        chatControl.isPersonalChannel = NO;
        NSLog(@"client Channel Selection");
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
