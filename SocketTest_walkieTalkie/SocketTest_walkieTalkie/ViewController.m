//
//  ViewController.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/26/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "ViewController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface ViewController ()

@property (nonatomic, strong) GCDAsyncUdpSocket *currentUDPSocket;
@property (weak, nonatomic) IBOutlet UITextView *textFieldForMessages;
@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   NSError *error = nil;
    self.currentUDPSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.currentUDPSocket bindToPort:8192 error:&error];
    if (![self.currentUDPSocket beginReceiving:&error]) {
        NSLog(@"receive failed");
    };

    NSString *myIP = [self getIPAddress];
    NSLog(@"my IP %@", myIP);
    self.textFieldForMessages.text = [NSString stringWithFormat:@"my IP - %@", myIP];
//    NSString *mylocalAddress = self.currentUDPSocket.localHost;
//    [self.currentUDPSocket sendData:[myIP dataUsingEncoding:NSUTF8StringEncoding] toHost:@"192.168.1.112" port:8192 withTimeout:-1 tag:1];
    
//    if ([self.currentUDPSocket connectToHost:@"192.168.1.112" onPort:8192 error:&error]) {
//        NSLog(@"Connected");
//        [self.currentUDPSocket sendData:[myIP dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
//    }
    // Do any additional setup after loading the view, typically from a nib.
    
}
- (IBAction)sendTapped:(id)sender {
    
    
//    NSData *someData = [self.portTextField.text dataUsingEncoding:NSUTF16StringEncoding];
//    const void *bytes = [someData bytes];
//    int length = [someData length];
//    
//    //Easy way
//    uint16_t *crypto_data = (uint16_t*)bytes;

//    {"type":1,"ip_address":"192.168.101","device_name":"Tamal","device_id":"fasfasf","message":"hi from android","port":8192}
    
//    [NSString stringWithFormat:@"{\"type\":1,\"ip_address\":\"192.168.101\",\"device_name\":\"Tamal\",\"device_id\":\"fasfasf\",\"message\":\"hi from android\",\"port\":8192}"]
   
    [self.currentUDPSocket sendData:[@"{\"type\":1,\"ip_address\":\"192.168.101\",\"device_name\":\"Rabi_dem0\",\"device_id\":\"fasfsajsdhasasf\",\"message\":\"hi from iphone\",\"port\":8192}" dataUsingEncoding:NSUTF8StringEncoding] toHost:self.ipTextField.text port:8192 withTimeout:-1 tag:0];
}

-(void)connectToHostWithIP:(NSString *)ipAddress port:(uint16_t)port {
     NSError *error = nil;
    [self.currentUDPSocket connectToHost:ipAddress onPort:8192 error:&error];
}

-(void)sendMessage:(NSString *)message{
    NSString *amessage = @"Something";
    [self.currentUDPSocket sendData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
}

- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"Datasent");
    self.textFieldForMessages.text = @"data Sent successfully";
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
      NSLog(@"Failed");
    self.textFieldForMessages.text = @"data Send failed";

}

/**
 * Called when the socket has received the requested datagram.
 **/


-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
   
    NSLog(@"received");
    NSString *sentdata = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    struct sockaddr_in *fromAddressV4 = (struct sockaddr_in *)address.bytes;
    char *fromIPAddress = inet_ntoa(fromAddressV4 -> sin_addr);
    NSString *ipAddress = [[NSString alloc] initWithUTF8String:fromIPAddress];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
    self.textFieldForMessages.text = @"data recieved successfully";


}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"SocketClosed");
    self.textFieldForMessages.text = @"socket closed.";


}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}




@end
