//
//  StartPageViewController.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/28/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "StartPageViewController.h"
#import "ChatViewController.h"
//#import "User.h"
//#import "UserHandler.h"

@interface StartPageViewController ()

@property (weak, nonatomic) IBOutlet UILabel *testLabel;
@property (strong, nonatomic) NSMutableArray *requesterUserArray;

@end

@implementation StartPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.requesterUserArray = [NSMutableArray new];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:ACTIVEUSERLISTKEY]) {
        
        NSArray *activeDeviceList =[[NSArray alloc] initWithObjects:[[MessageHandler sharedHandler] getIPAddress], nil];
        [[NSUserDefaults standardUserDefaults] setObject:activeDeviceList forKey:ACTIVEUSERLISTKEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[asyncUDPConnectionHandler sharedHandler] createSocketWithPort:WALKIETALKIE_UINT_PORT_sender];
    [[asyncUDPConnectionHandler sharedHandler] createVoiceSocketWithPort:WALKIETALKIE_VOICE_LISTENER];
    [[asyncUDPConnectionHandler sharedHandler] createVoiceStreamerSocketWithPort:WALKIETALKIE_VOICE_STREAMER_PORT];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foreignChannelCreated:) name:FOREIGN_CHANNEL_CREATED_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewDeviceToNetWorkDeviceList:) name:NEW_DEVICE_CONNECTED_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(confirmNewDeviceToNetWorkDeviceList:) name:NEW_DEVICE_CONFIRMED_NOTIFICATIONKEY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDeviceFromActiveDeviceList:) name:CHANNEL_LEFT_NOTIFICATIONKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeUserFromList:) name:USER_LEFT_SYSTEM_NOTIFICATIONKEY object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oneToOneChatRequest:) name:ONE_TO_ONE_CHAT_REQUEST_NOTIFICATIONKEY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oneToOneChatAccepted:) name:ONE_TO_ONE_CHAT_ACCEPT_NOTIFICATIONKEY object:nil];

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifySelfPresenceToNetwork)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ApplicationIsInactive)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
    [self.view addGestureRecognizer:aTap];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    
//    self.title = @"Main Menu";
}

-(void)viewDidAppear:(BOOL)animated{

    [self notifySelfPresenceToNetwork];


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)ScreenTapped{
    [self.view endEditing:YES];
}


-(void)notifySelfPresenceToNetwork{

    NSString *requestInfoMessage = [[MessageHandler sharedHandler] requestInfoAtStartMessage];
    
    [[asyncUDPConnectionHandler sharedHandler] enableBroadCast];
    for (int i =1 ; i<=254; i++) {
        NSString *ipAddressTosendData = [NSString stringWithFormat:@"%@%d",[[NSUserDefaults standardUserDefaults] objectForKey:IPADDRESS_FORMATKEY],i];
        if (![ipAddressTosendData isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
            NSLog(@"ip to send %@", ipAddressTosendData);
            [[asyncUDPConnectionHandler sharedHandler]sendMessage:requestInfoMessage toIPAddress:ipAddressTosendData];
        }
    }
    
//    [[asyncUDPConnectionHandler sharedHandler]sendMessage:requestInfoMessage toIPAddress:@"255.255.255.255"];

//    [[asyncUDPConnectionHandler sharedHandler] disableBroadCast];

}

-(void)ApplicationIsInactive{
    
    NSString *signOffMessage = [[MessageHandler sharedHandler] leftApplicationMessage];
    NSArray *activeIPs = [[NSUserDefaults standardUserDefaults] objectForKey:ACTIVEUSERLISTKEY];
    for (int i =0 ; i<activeIPs.count; i++) {
        NSString *ipAddressTosendData = [activeIPs objectAtIndex: i];
        if (![ipAddressTosendData isEqualToString:[[MessageHandler sharedHandler] getIPAddress]]) {
            NSLog(@"ip to send %@", ipAddressTosendData);
            [[asyncUDPConnectionHandler sharedHandler]sendMessage:signOffMessage toIPAddress:ipAddressTosendData];
        }
    }
}

-(void) addNewDeviceToNetWorkDeviceList:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSLog (@"Successfully received New device Presence notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    //Save The User In UserHander
    [[UserHandler sharedInstance] addUserWithIP:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]
                                       deviceID:[jsonDict objectForKey:JSON_KEY_DEVICE_ID]
                                           name:[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]
                                      andActive:YES];
    
    
    int count = [[[UserHandler sharedInstance] getUsers] count];
    NSLog(@"UserHandler Count %d", count);
    
    NSMutableArray *networkDevices = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:ACTIVEUSERLISTKEY]];
    if ([networkDevices indexOfObject:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]] == NSNotFound) {
        [networkDevices addObject:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:networkDevices forKey:ACTIVEUSERLISTKEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"Devices %@", networkDevices);

    NSString *acknowledgeDeviceInNetWorkMessage = [[MessageHandler sharedHandler] acknowledgeDeviceInNetwork];
    [[asyncUDPConnectionHandler sharedHandler]sendMessage:acknowledgeDeviceInNetWorkMessage toIPAddress:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]];

    self.testLabel.text = [NSString stringWithFormat:@"ipaddress added %@ acknowledgement sent \n devices %@", [jsonDict objectForKey:JSON_KEY_IP_ADDRESS ], networkDevices];
}

-(void) confirmNewDeviceToNetWorkDeviceList:(NSNotification*)notification{
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    //Save The User In UserHander
    [[UserHandler sharedInstance] addUserWithIP:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]
                                       deviceID:[jsonDict objectForKey:JSON_KEY_DEVICE_ID]
                                           name:[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]
                                      andActive:YES];
    
    int count = [[[UserHandler sharedInstance] getUsers] count];
    NSLog(@"UserHandler Count %d", count);
    
    
    NSMutableArray *networkDevices = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:ACTIVEUSERLISTKEY]];
    if ([networkDevices indexOfObject:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]] == NSNotFound) {
        [networkDevices addObject:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:networkDevices forKey:ACTIVEUSERLISTKEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"Devices %@", networkDevices);
    self.testLabel.text = [NSString stringWithFormat:@"ipaddress added %@ acknowledgement receieved \n Devices %@", [jsonDict objectForKey:JSON_KEY_IP_ADDRESS ], networkDevices];

}

-(void) removeDeviceFromActiveDeviceList:(NSNotification*)notification{
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSLog (@"Successfully receieved  device sign off request notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    NSMutableArray *networkDevices = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:ACTIVEUSERLISTKEY]];
    if (![jsonDict objectForKey:JSON_KEY_CHANNEL]) {
        if ([networkDevices indexOfObject:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]] != NSNotFound) {
            [networkDevices removeObjectAtIndex:[networkDevices indexOfObject:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]]];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:networkDevices forKey:ACTIVEUSERLISTKEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"Devices %@", networkDevices);
    self.testLabel.text = [NSString stringWithFormat:@"ipaddress removed %@ \n Devices %@", [jsonDict objectForKey:JSON_KEY_IP_ADDRESS ], networkDevices];
}

- (void)removeUserFromList:(NSNotification *)sender {
    
    NSDictionary* userInfo = sender.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    //Remove The User from UserHander
    
    [[UserHandler sharedInstance] removeUserofIP:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]
                                    andDeviceID:[jsonDict objectForKey:JSON_KEY_DEVICE_ID]];
}



-(void) foreignChannelCreated:(NSNotification*)notification{
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSLog (@"Successfully received foreign Channel Created notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    [self saveForeignChannelinUserDefaultsWithChannelData:jsonDict];

}

- (void)oneToOneChatRequest:(NSNotification *)sender {
    
//    if(![[self.navigationController visibleViewController] isKindOfClass:[ChatViewController class]]){
//    }
    
    NSDictionary* userInfo = sender.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];

    User *requesterUser = [[User alloc] initWithIP:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]
                                         deviceID:[jsonDict objectForKey:JSON_KEY_DEVICE_ID]
                                             name:[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]
                                        andActive:YES];
    
    if([[ChannelHandler sharedHandler] isAcceptedOponentUser:requesterUser]){
        
        //Already Accepted, send confirmation
        NSString * message = [[MessageHandler sharedHandler] oneToOneChatAcceptMessage];
        [[asyncUDPConnectionHandler sharedHandler] sendMessage:message toIPAddress:requesterUser.deviceIP];
        NSLog(@"Sent confirmation: %@", message);
        
        //Update current Oponent User
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ONE_TO_ONE_CHAT_ACCEPT_FROM_STARTPAGE_NOTIFICATIONKEY object:nil userInfo:userInfo];
        

        return;
    }
    
    int index = [self getIndexInRequesterArray:requesterUser];
    
    if(index < 0){
        
        [self.requesterUserArray addObject:requesterUser];
        index = (self.requesterUserArray.count - 1);
    }
    
    NSString *message =  [NSString stringWithFormat:@"%@ wants to chat you in personal.", [jsonDict objectForKey:JSON_KEY_DEVICE_NAME]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Personal Chatting Request"
                                                    message: message
                                                   delegate: self
                                          cancelButtonTitle:@"Decline"
                                          otherButtonTitles:@"Accept", nil];

    alert.tag = index;
    [alert show];
}


- (void)oneToOneChatAccepted:(NSNotification *)sender {
    
    NSDictionary* userInfo = sender.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    User *accepterUser = [[User alloc] initWithIP:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]
                                          deviceID:[jsonDict objectForKey:JSON_KEY_DEVICE_ID]
                                              name:[jsonDict objectForKey:JSON_KEY_DEVICE_NAME]
                                         andActive:YES];
    
    
    [[ChannelHandler sharedHandler] setActive:YES toUser:accepterUser];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ONE_TO_ONE_CHAT_ACCEPT_FROM_STARTPAGE_NOTIFICATIONKEY object:nil userInfo:userInfo];
}



#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    int index = alertView.tag;
    User *requesterUser = (User *) self.requesterUserArray[index];
    
    if(requesterUser){
        if(buttonIndex == 0){
            
            //Decline, send Reply
            NSString * message = [[MessageHandler sharedHandler] oneToOneChatDeclineMessage];
            [[asyncUDPConnectionHandler sharedHandler] sendMessage:message toIPAddress:requesterUser.deviceIP];
            
        }else if(buttonIndex == 1){
            
            //Accept, send confirmation
            [[ChannelHandler sharedHandler] addOponetUserToAcceptedList:requesterUser];

            NSString * message = [[MessageHandler sharedHandler] oneToOneChatAcceptMessage];
            [[asyncUDPConnectionHandler sharedHandler] sendMessage:message toIPAddress:requesterUser.deviceIP];
            
            //navigate to chatview controller
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ChatViewController *chatVC = (ChatViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ChatViewControllerID"];
            
            //vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            chatVC.isPersonalChannel = YES;
            chatVC.oponentUser = requesterUser;
            
            [self.navigationController pushViewController:chatVC animated:YES];
        }
    }
}


-(int)getIndexInRequesterArray:(User *) reqUser {
    
    
    for (int index = 0; index < self.requesterUserArray.count; index++) {
        
        User *user = self.requesterUserArray[index];
        
        if([user.deviceID isEqualToString:reqUser.deviceID] && [user.deviceIP isEqualToString:reqUser.deviceIP]){
            
            return index;
        }
    }
    
    return -1;
}






-(void)saveForeignChannelinUserDefaultsWithChannelData:(NSDictionary *)jsonDict{
    Channel *newChannel = [[Channel alloc] initWithChannelID:[[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue]];
    newChannel.foreignChannelHostDeviceID = [jsonDict objectForKey:JSON_KEY_DEVICE_ID];
    newChannel.foreignChannelHostIP = [jsonDict objectForKey:JSON_KEY_IP_ADDRESS];
    newChannel.foreignChannelHostName = [jsonDict objectForKey:JSON_KEY_DEVICE_NAME];
    [newChannel saveForeignChannel:newChannel];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
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
