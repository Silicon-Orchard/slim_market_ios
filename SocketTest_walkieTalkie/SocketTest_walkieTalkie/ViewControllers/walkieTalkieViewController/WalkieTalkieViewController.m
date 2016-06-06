//
//  WalkieTalkieViewController.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "WalkieTalkieViewController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface WalkieTalkieViewController ()

@property (weak, nonatomic) IBOutlet UITextField *channel_IDTextfield;
@property (weak, nonatomic) IBOutlet UITextField *joinChannelIDTextField;
@property (weak, nonatomic) IBOutlet UILabel *displayLabelTest;


@end

@implementation WalkieTalkieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MessageReceieved:) name:MESSAGE_RECEIVED_NOTIFICATIONKEY object:nil];
    [[asyncUDPConnectionHandler sharedHandler] createSocketWithPort:WALKIETALKIE_UINT_PORT];
    
   
    // Do any additional setup after loading the view.
}

-(void) MessageReceieved:(NSNotification*)notification
{
    if ([notification.name isEqualToString:MESSAGE_RECEIVED_NOTIFICATIONKEY])
    {
        NSDictionary* userInfo = notification.userInfo;
        NSData* receivedData = (NSData*)userInfo[@"receievedData"];
        NSLog (@"Successfully received test notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
        NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
        NSLog(@"JsonDICT %@", jsonDict);
        NSNumber *messageType = [jsonDict objectForKey:JSON_KEY_TYPE];
        int type = [messageType intValue];
        switch (type) {
            case 5:
                [self saveForeignChannelinUserDefaultsWithChannelData:jsonDict];
                self.displayLabelTest.text = @"Channel created notification Received";
                break;
            case 6:
                [self addNewChannelToChannelListForJoinedChannelWithChannelData:jsonDict];
                self.displayLabelTest.text = @"Channel join request notification Received";

                break;
            case 7:
                self.displayLabelTest.text = @"JoinConfirmed";
                break;
                
            default:
                break;
        }
        
        
    }
}


-(void)saveForeignChannelinUserDefaultsWithChannelData:(NSDictionary *)jsonDict{
    Channel *newChannel = [[Channel alloc] initWithChannelID:[[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue]];
    newChannel.foreignChannelHostDeviceID = [jsonDict objectForKey:JSON_KEY_DEVICE_ID];
    newChannel.foreignChannelHostIP = [jsonDict objectForKey:JSON_KEY_IP_ADDRESS];
    newChannel.foreignChannelHostName = [jsonDict objectForKey:JSON_KEY_DEVICE_NAME];
    [newChannel saveForeignChannel:newChannel];
}


-(void)addNewChannelToChannelListForJoinedChannelWithChannelData:(NSDictionary *)channelData{

    Channel *blankChannel = [[Channel alloc] init];
    [blankChannel addUserToChannelWithChannelID:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue] userIP:[channelData objectForKey:JSON_KEY_IP_ADDRESS] userName:[channelData objectForKey:JSON_KEY_DEVICE_NAME] userID:[channelData objectForKey:JSON_KEY_DEVICE_ID]];
    NSString *confirmationMessageForJoiningChannel = [[MessageHandler sharedHandler] confirmJoiningForChannelID:[[channelData objectForKey:JSON_KEY_CHANNEL] intValue] channelName:[channelData objectForKey:JSON_KEY_DEVICE_NAME]];
    [[asyncUDPConnectionHandler sharedHandler]sendMessage:confirmationMessageForJoiningChannel toIPAddress:[channelData objectForKey:JSON_KEY_IP_ADDRESS]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)createChannelWithChannelID:(int)channelID{

    Channel *newChannel = [[Channel alloc] initWithChannelID:channelID];
    
    [newChannel saveChannel:newChannel];
    
    NSString *channelCreatNotificationMessage = [[MessageHandler sharedHandler] newChannelCreatedMessageWithChannelID:channelID deviceName:@"nameForchannel"];
    
    [[asyncUDPConnectionHandler sharedHandler] enableBroadCast];
    for (int i =1 ; i<=254; i++) {
        [[asyncUDPConnectionHandler sharedHandler]sendMessage:channelCreatNotificationMessage toIPAddress:[NSString stringWithFormat:@"%@%d",[[NSUserDefaults standardUserDefaults] objectForKey:IPADDRESS_FORMATKEY],i]];
    }
//    [[asyncUDPConnectionHandler sharedHandler] disableBroadCast];
    [ChannelHandler sharedHandler].currentlyActiveChannelID = channelID;
    [ChannelHandler sharedHandler].isHost = YES;


//    [newChannel addUserToChannelWithChannelID:channelID userIP:@"6666666" userName:@"Fautest" userID:@"DFDGSFDGSDF"];
//    [newChannel addUserToChannelWithChannelID:channelID userIP:@"6666666" userName:@"Fautest" userID:@"DFDGSFDGSDF"];
//    [newChannel addUserToChannelWithChannelID:channelID userIP:@"6666666" userName:@"Fautest" userID:@"DFDGSFDGSDF"];
//
//    [newChannel addUserToChannelWithChannelID:channelID userIP:@"6666666" userName:@"Fautest" userID:@"DFDGSFDGSDF"];
//
//
//    
//    Channel *checkChannel = [newChannel geChannel:channelID];

}

-(void)joinChannelWithChannelID:(int)channelID{
    
    Channel *newChannel = [[Channel alloc] init];
    
    Channel *foreignChannel = [newChannel getForeignChannel:channelID];
    
    NSString *foreignChannelOwnerIPaddress;
    if (foreignChannel) {
        foreignChannelOwnerIPaddress = foreignChannel.foreignChannelHostIP;
    }
    else{
        NSLog(@"channelNotfound");
        return;
    }
    
    NSString *channelJoinNotificationMessage = [[MessageHandler sharedHandler] joinChannelCreatedMessageWithChannelID:foreignChannel.channelID deviceName:@"JoinChannelDevice"];
    
    [[asyncUDPConnectionHandler sharedHandler]sendMessage:channelJoinNotificationMessage toIPAddress:foreignChannelOwnerIPaddress];

    
    //    [newChannel addUserToChannelWithChannelID:channelID userIP:@"6666666" userName:@"Fautest" userID:@"DFDGSFDGSDF"];
    //    [newChannel addUserToChannelWithChannelID:channelID userIP:@"6666666" userName:@"Fautest" userID:@"DFDGSFDGSDF"];
    //    [newChannel addUserToChannelWithChannelID:channelID userIP:@"6666666" userName:@"Fautest" userID:@"DFDGSFDGSDF"];
    //
    //    [newChannel addUserToChannelWithChannelID:channelID userIP:@"6666666" userName:@"Fautest" userID:@"DFDGSFDGSDF"];
    //
    //
    //
    //    Channel *checkChannel = [newChannel geChannel:channelID];
    
}



- (IBAction)joinChannelTapped:(id)sender {
    
    [self joinChannelWithChannelID:[self.joinChannelIDTextField.text intValue]];
    
}



- (IBAction)createChannelTapped:(id)sender {
    
    [self createChannelWithChannelID:[self.channel_IDTextfield.text integerValue]];
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
