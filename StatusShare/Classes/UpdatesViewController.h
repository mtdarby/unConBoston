//
//  UpdatesViewController.h
//  StatusShare
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import "KinveyFriendsUpdate.h"

@interface UpdatesCell : UITableViewCell 
@end

@interface UpdatesViewController : PullRefreshTableViewController <UITextFieldDelegate, KCSPersistableDelegate, KCSEntityDelegate>

- (void)removeUpdate:(KinveyFriendsUpdate *)update;

@end
