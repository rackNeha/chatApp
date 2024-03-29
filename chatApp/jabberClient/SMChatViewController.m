//
//  SMChatViewController.m
//  jabberClient
//
//  Created by cesarerocchi on 7/16/11.
//  Copyright 2011 studiomagnolia.com. All rights reserved.
//

#import "SMChatViewController.h"
#import "XMPP.h"
#import "NSString+Utils.h"


@implementation SMChatViewController {
    CGSize contentSize;
}


@synthesize messageField, chatWithUser, tView;


- (AppDelegate *)appDelegate {
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (XMPPStream *)xmppStream {
	return [[self appDelegate] xmppStream];
}

- (id) initWithUser:(NSString *) userName {

	if (self = [super init]) {
		
		chatWithUser = userName; // @ missing
		turnSockets = [[NSMutableArray alloc] init];
	}
	
	return self;

}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	self.tView.delegate = self;
	self.tView.dataSource = self;
	[self.tView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	
	messages = [[NSMutableArray alloc ] init];
	
	AppDelegate *del = [self appDelegate];
	del._messageDelegate = self;
	[self.messageField becomeFirstResponder];

	XMPPJID *jid = [XMPPJID jidWithString:@"cesare@hazardhost.local"];
	
	NSLog(@"Attempting TURN connection to %@", jid);
	
	TURNSocket *turnSocket = [[TURNSocket alloc] initWithStream:[self xmppStream] toJID:jid];
	
	[turnSockets addObject:turnSocket];
	
	[turnSocket startWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	
}

- (void)turnSocket:(TURNSocket *)sender didSucceed:(GCDAsyncSocket *)socket {
	
	NSLog(@"TURN Connection succeeded!");
	NSLog(@"You now have a socket that you can use to send/receive data to/from the other person.");
		
	[turnSockets removeObject:sender];
}

- (void)turnSocketDidFail:(TURNSocket *)sender {
	
	NSLog(@"TURN Connection failed!");
	[turnSockets removeObject:sender];
	
}



#pragma mark -
#pragma mark Actions

- (IBAction) closeChat {

	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendMessage {
	
    NSString *messageStr = self.messageField.text;
	
    if([messageStr length] > 0) {
		
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
		
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:chatWithUser];
        [message addChild:body];
		
        [self.xmppStream sendElement:message];
		
		self.messageField.text = @"";
		

		NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
		[m setObject:[messageStr substituteEmoticons] forKey:@"msg"];
		[m setObject:@"you" forKey:@"sender"];
		[m setObject:[NSString getCurrentTime] forKey:@"time"];
		
		[messages addObject:m];
		[self.tView reloadData];
        m = nil;
        
        
        
        
        
		
    }
    
  	NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1
												   inSection:0];
	
	[self.tView scrollToRowAtIndexPath:topIndexPath
					  atScrollPosition:UITableViewScrollPositionMiddle
							  animated:YES];
    [messageField resignFirstResponder];
}


#pragma mark -
#pragma mark Table view delegates

static CGFloat padding = 20.0;



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	NSDictionary *s = (NSDictionary *) [messages objectAtIndex:indexPath.row];
	
	static NSString *CellIdentifier = @"MessageCellIdentifier";
	
	SMMessageViewTableCell *cell = (SMMessageViewTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[SMMessageViewTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
	}

	NSString *sender = [s objectForKey:@"sender"];
	NSString *message = [s objectForKey:@"msg"];
	NSString *time = [s objectForKey:@"time"];
    
    cell.messageContentView.text = message;
    cell.accessoryType = UITableViewCellAccessoryNone;
	cell.userInteractionEnabled = NO;
	
	CGSize  textSize = { 260, 10000.0 };
//	CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:13]
//					  constrainedToSize:textSize 
//						  lineBreakMode:UILineBreakModeWordWrap];
    
//    CGSize size = [message boundingRectWithSize:textSize
//                                        options:NSStringDrawingUsesDeviceMetrics
//                                     attribute:@{
//                                                  NSFontAttributeName: [UIFont boldSystemFontOfSize:13]
//                                                  }
//                                        context:(NSStringDrawingContext *)];

    CGSize size = [cell.messageContentView sizeThatFits:textSize];

//    CGSize size = [message boundingRectWithSize:textSize
//                                    options:NSStringDrawingUsesLineFragmentOrigin
//                                 attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:13], NSFontAttributeName, nil]
//                                    context:nil].size;
    
    
	size.width += (padding/2);
	
	
	

	UIImage *bgImage = nil;
	
		
	if ([sender isEqualToString:@"you"]) { // left aligned
	
		bgImage = [[UIImage imageNamed:@"orange.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:10];
		
        [cell.messageContentView setFrame:CGRectMake(padding, (padding*2), size.width, size.height)];
		
		[cell.bgImageView setFrame:CGRectMake( cell.messageContentView.frame.origin.x - padding/2,
											  cell.messageContentView.frame.origin.y - padding/2, 
											  size.width+padding, 
											  size.height+padding)];
				
	} else {
	
		bgImage = [[UIImage imageNamed:@"aqua.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
	
		[cell.messageContentView setFrame:CGRectMake(320 - size.width - padding,
													 (padding*2),
													 size.width,
													 size.height)];
		
		[cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, 
											  cell.messageContentView.frame.origin.y - padding/2, 
											  size.width+padding, 
											  size.height+padding)];
		
	}
	
    cell.bgImageView.image = bgImage;
	cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", sender, time];
    
    
	
	
	return cell;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSDictionary *dict = (NSDictionary *)[messages objectAtIndex:indexPath.row];
	NSString *msg = [dict objectForKey:@"msg"];
	
	CGSize  textSize = { 320.0, 10000.0 };
	CGSize size = [msg sizeWithFont:[UIFont boldSystemFontOfSize:13]
				  constrainedToSize:textSize];

    
//    CGSize size = [msg boundingRectWithSize:textSize
//                                    options:NSStringDrawingUsesLineFragmentOrigin
//                                 attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:13], NSFontAttributeName, nil]
//                                                           context:nil].size;
	

	size.height += padding*2;
	
	CGFloat height = size.height < 75 ? 75 : size.height;
	return height;
	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [messages count];
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
	
}


#pragma mark -
#pragma mark Chat delegates


- (void)newMessageReceived:(NSDictionary *)messageContent {
	
	NSString *m = [messageContent objectForKey:@"msg"];
	
	[messageContent setValue:[m substituteEmoticons] forKey:@"msg"];
	[messageContent setValue:[NSString getCurrentTime] forKey:@"time"];
	[messages addObject:messageContent];
	[self.tView reloadData];

	NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1 
												   inSection:0];
	
	[self.tView scrollToRowAtIndexPath:topIndexPath 
					  atScrollPosition:UITableViewScrollPositionMiddle 
							  animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
