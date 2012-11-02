//
//  AttendeesViewController.h
//  StatusShare
//
//  Created by Michelle Darby on 10/26/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AttendeesViewController : UITableViewController
{
    IBOutlet UITableView *_tableview;
}

@property (nonatomic) NSMutableSet* attendees;


@end
