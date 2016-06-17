//
//  Constants.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define kBufferByteSize 8096


#define WALKIETALKIE_UINT_PORT ((uint16_t) 43321)
#define WALKIETALKIE_UINT_PORT_sender ((uint16_t) 43324)
#define WALKIETALKIE_VOICE_LISTENER ((uint16_t) 43322)
#define WALKIETALKIE_TCP_SENDER ((uint16_t) 43325)
#define WALKIETALKIE_TCP_LISTENER ((uint16_t) 43326)
#define WALKIETALKIE_VOICE_STREAMER_PORT ((uint16_t) 43327)

#define CHUNKSIZE ((int) 3000)


#define TYPE_MESSAGE ((int) 1)
#define TYPE_ADD_CLIENT ((int) 2)
#define TYPE_REQUEST_INFO ((int) 3)
#define TYPE_RECEIVE_INFO ((int) 4)
#define TYPE_CREATE_CHANNEL ((int) 5)
#define TYPE_JOIN_CHANNEL ((int) 6)
#define TYPE_CHANNEL_FOUND ((int) 7)
#define TYPE_CHANNEL_DUPLICATE ((int) 8)
#define TYPE_LEFT_CHANNEL ((int) 9)
#define TYPE_LEFT_APPLICATION ((int) 10)
#define TYPE_ONE_TO_ONE_CHAT_REQUEST ((int) 11)
#define TYPE_ONE_TO_ONE_CHAT_ACCEPT ((int) 12)
#define TYPE_ONE_TO_ONE_CHAT_DECLINE ((int) 13)


#define TYPE_VOICE_MESSAGE ((int) 15)
#define TYPE_VOICE_MESSAGE_REPEAT_REQUEST ((int) 16)
#define TYPE_VOICE_STREAM ((int) 17)




#define JSON_KEY_IP_ADDRESS @"ip_address"
#define JSON_KEY_DEVICE_NAME @"device_name"
#define JSON_KEY_DEVICE_ID @"device_id"
#define JSON_KEY_MESSAGE @"message"
#define JSON_KEY_PORT @"port"
#define JSON_KEY_TYPE @"type"
#define JSON_KEY_CLIENT_IP @"client_ip"
#define JSON_KEY_CLIENT_PORT @"client_port"
#define JSON_KEY_CHANNEL @"channel_id"
#define JSON_KEY_CHANNEL_MEMBERS @"channel_members"
#define JSON_KEY_VOICE_MESSAGE @"voice_message"
#define JSON_KEY_VOICE_MESSAGE_CHUNKCOUNT @"voice_message_chunkCount"
#define JSON_KEY_VOICE_MESSAGE_CURRENT_CHUNK @"voice_message_current_chunk"
#define JSON_KEY_VOICE_MESSAGE_FILE_NAME @"voice_message_file_name"


#define CURRENTUSERKEY_FOR_USERDEFAULTS @"CurrentUserKey"
#define SAVED_CHANNELS_KEY_FOR_USERDEFAULS @"myChannelsKey"
#define FOREIGN_NEWLYCREATED_CHANNELS_KEY_FOR_USERDEFAULS @"myChannelsKey"
#define DEVICE_UUID_KEY_FORUSERDEFAULTS @"UUIDkey"
#define ACTIVEUSERLISTKEY @"activeUserListKey"
#define IPADDRESS_FORMATKEY @"IPAddressFormatKey"

#define MESSAGE_RECEIVED_NOTIFICATIONKEY @"dataReceievedNotificationKey"
#define FOREIGN_CHANNEL_CREATED_NOTIFICATIONKEY @"foreignChannelCreatedNotification"
#define JOINCHANNEL_REQUEST_NOTIFICATIONKEY @"JoinChannelRequestReceivedNotification"
#define JOINCHANNEL_CONFIRM_NOTIFICATIONKEY @"JoinChannelConfirmationReceivedNotification"
#define CHATMESSAGE_RECEIVED_NOTIFICATIONKEY @"ChatMessageReceivedNotification"
#define CHANNEL_LEFT_NOTIFICATIONKEY @"leaveChannelMessageReceivedNotification"
#define NEW_DEVICE_CONNECTED_NOTIFICATIONKEY @"newdeviceConnectedNotification"
#define NEW_DEVICE_CONFIRMED_NOTIFICATIONKEY @"newdeviceConfirmedNotification"
#define VOICE_MESSAGE_RECEIEVED_NOTIFICATIONKEY @"voiceMessageReceivedNotification"
#define TCP_VOICE_MESSAGE_RECEIEVED_NOTIFICATIONKEY @"TCPvoiceMessageReceivedNotification"
#define UDP_VOICE_MESSAGE_REPEAR_REQUEST_NOTIFICATIONKEY @"UDPvoiceMessageRepeatRequestNotification"
#define VOICE_STREAM_RECEIEVED_NOTIFICATIONKEY @"voiceStreamReceivedNotification"

#define USER_LEFT_SYSTEM_NOTIFICATIONKEY @"userLeftSystemNotification"





#define ONE_TO_ONE_CHAT_REQUEST_NOTIFICATIONKEY @"OneToOneChatRequestNotification"
#define ONE_TO_ONE_CHAT_ACCEPT_NOTIFICATIONKEY @"OneToOneChatAcceptNotification"
#define ONE_TO_ONE_CHAT_DECLINE_NOTIFICATIONKEY @"OneToOneChatDeclineNotification"

#define ONE_TO_ONE_CHAT_ACCEPT_FROM_STARTPAGE_NOTIFICATIONKEY @"acceptMessageFromStartPageNotification"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]






#endif /* Constants_h */
