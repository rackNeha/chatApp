//
//  SMChatViewController.h
//  jabberClient
//
//  Created by cesarerocchi on 7/16/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMBuddyListViewController.h"
#import "XMPP.h"
#import "TURNSocket.h"
#import "SMMessageViewTableCell.h"

@interface SMChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SMMessageDelegate> {

	UITextField		*messageField;
	NSString		*chatWithUser;
	UITableView		*tView;
	NSMutableArray	*messages;
	NSMutableArray *turnSockets;
	
}


@property (nonatomic,strong) IBOutlet UITextField *messageField;
@property (nonatomic,strong) NSString *chatWithUser;
@property (nonatomic,strong) IBOutlet UITableView *tView;

- (id) initWithUser:(NSString *) userName;
- (IBAction) sendMessage;
- (IBAction) closeChat;

@end
