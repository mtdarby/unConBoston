//
//  AuthorViewController.h
//  StatusShare
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KinveyFriendsUpdate.h"
#import "UpdatesViewController.h"

@interface AuthorViewController : UITableViewController
{
    __weak IBOutlet UILabel *_sessionTitleLabel;
    __weak IBOutlet UILabel *_sessionLeaderLabel;
    __weak IBOutlet UILabel *_sessionLocationLabel;
    __weak IBOutlet UILabel *_sessionTimeLabel;
    __weak IBOutlet UILabel *_sessionAttendeesLabel;
    __weak IBOutlet UILabel *_sessionDescriptionLabel;
}

@property (nonatomic) KinveyFriendsUpdate* update;
@property (nonatomic) UpdatesViewController *updatesViewController;



@end
