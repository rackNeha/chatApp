//
//  AppDelegate.h
//  chatApp
//
//  Created by Radio Active on 11/02/14.
//  Copyright (c) 2014 Rackinfotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPRoster.h"
#import "XMPP.h"
#import "SMChatDelegate.h"
#import "SMMessageDelegate.h"

@class SMBuddyListViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    SMBuddyListViewController *viewController;
	
	XMPPStream *xmppStream;
	XMPPRoster *xmppRoster;
	
	NSString *password;
	
	BOOL isOpen;
	
//	id <SMChatDelegate> *_chatDelegate;
//	NSObject <SMMessageDelegate> *_messageDelegate;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, readonly) XMPPRoster *xmppRoster;

@property (nonatomic, weak) id _chatDelegate;
@property (nonatomic, weak) id _messageDelegate;

- (BOOL)connect;
- (void)disconnect;

@end
