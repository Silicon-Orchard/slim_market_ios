//
//  IPChangeNotifier.m
//  SocketTest_walkieTalkie
//
//  Created by Mehedi Hasan on 6/28/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "IPChangeNotifier.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
@implementation IPChangeNotifier

-(instancetype) initWithTimer:(float)time andDelegate:(id)del {
    
    if (self = [super init]) {
        
        changeTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(checkForChange) userInfo:nil repeats:YES];
        prevIP = @"";
        changeDelegate = del;
    }
    
    return self;
}

-(void) checkForChange {
    NSString *currentIP = [IPChangeNotifier getIPAddress];
    if (![currentIP isEqualToString:prevIP]) {
        
        if (changeDelegate && [changeDelegate respondsToSelector:@selector(IPChangeDetected:previousIP:)]){
            [changeDelegate IPChangeDetected:currentIP previousIP:prevIP];
        }
        prevIP = currentIP;
    }
}

+ (NSString *)getIPAddress {
    
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    // retrieve the current interfaces - returns 0 on success
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            if(sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                NSLog(@"NAME: \"%@\" addr: %@", name, addr); // see for yourself
                
                if([name isEqualToString:@"en0"]) {
                    // Interface is the wifi connection on the iPhone
                    wifiAddress = addr;
                } else
                    if([name isEqualToString:@"pdp_ip0"]) {
                        // Interface is the cell connection on the iPhone
                        cellAddress = addr;
                    }
            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSString *addr = wifiAddress ? wifiAddress : cellAddress;
    return addr ? addr : @"0.0.0.0";
} 
@end