//
//  jabberClientViewController.h
//  jabberClient
//
//  Created by cesarerocchi on 7/13/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SMLoginViewController.h"
#import "SMChatViewController.h"
#import "SMChatDelegate.h"

@interface SMBuddyListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SMChatDelegate> {
	
	UITableView *tView;
	NSMutableArray *onlineBuddies;
	
	UIView		*addBuddyView;	
	UITextField *buddyField;
	
	
}

@property (nonatomic,strong) IBOutlet UITableView *tView;

@property (nonatomic,strong) IBOutlet UIView *addBuddyView;
@property (nonatomic,strong) IBOutlet UITextField *buddyField;



- (IBAction) addBuddy;
- (IBAction) showLogin;


@end

