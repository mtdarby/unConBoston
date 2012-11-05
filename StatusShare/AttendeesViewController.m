//
//  AttendeesViewController.m
//  StatusShare
//
//  Created by Michelle Darby on 10/26/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import "AttendeesViewController.h"
#import <KinveyKit/KinveyKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>

#import "AppDelegate.h"
#import "KinveyFriendsUpdate.h"
#import "AttendeeCell.h"

@interface AttendeesViewController ()
{
    NSArray *_names;
    
    UIView *_overlayView;
    UILabel *_messageLabel;
}

@end

@implementation AttendeesViewController
@synthesize attendees;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Attendees";

    _names = @[];

    _overlayView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., 320., 600.)];
    _overlayView.backgroundColor = [UIColor clearColor];
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20., 10., 280., 50.)];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.textColor = [UIColor whiteColor];
    _messageLabel.lineBreakMode = UILineBreakModeWordWrap;
    _messageLabel.numberOfLines = 0;
    _messageLabel.font = [UIFont italicSystemFontOfSize:16.0f];
    
    if ([attendees count] <=0) {
        _overlayView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.75];
        _messageLabel.text = @"No one has registered for this event yet...you can be the first one!";
    }
    
    [_overlayView addSubview:_messageLabel];
    [_tableview addSubview:_overlayView];
    [_tableview bringSubviewToFront:_overlayView];
    
    KCSCollection* users = [[KCSClient sharedClient].currentUser userCollection];
    KCSCachedStore* userStore = [KCSCachedStore storeWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:users, KCSStoreKeyResource, [NSNumber numberWithInt:KCSCachePolicyNone], KCSStoreKeyCachePolicy, nil]];
    
    [userStore loadObjectWithID:[attendees allObjects]  withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        if (errorOrNil != nil) {
            _overlayView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.75];
            _messageLabel.text = @"Sorry, an internet connection is required to view the list of attendees.";
            
        } else if (objectsOrNil) {
            _names = objectsOrNil;
        }
        [_tableview reloadData];
    } withProgressBlock:nil];
}
- (void)viewDidUnload {
    _tableview = nil;
    [super viewDidUnload];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_tableview reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _names.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"Cell";
    
    AttendeeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        cell = [[AttendeeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    KCSUser *user = [_names objectAtIndex:indexPath.row];
    NSString *name = user.username;
    NSString *fbID = @"";
    
    NSDictionary *socialIdentity = [user getValueForAttribute:@"_socialIdentity"];
    if (socialIdentity != nil)
    {
        if ([socialIdentity objectForKey:@"facebook"] != nil)
        {
            NSDictionary *facebookIdentity = [socialIdentity objectForKey:@"facebook"];
            if (facebookIdentity != nil)
            {
                NSString *facebookName = [facebookIdentity objectForKey:@"name"];
                if ((facebookName != nil) && ([facebookName length] > 0)) {
                    name = facebookName;
                }
                NSString *facebookID = [facebookIdentity objectForKey:@"id"];
                if ((facebookID != nil) && ([facebookID length] > 0)) {
                    fbID = facebookID;
                }
            }
        }
        else if ([socialIdentity objectForKey:@"twitter"] != nil)
        {
            NSDictionary *twitterIdentity = [socialIdentity objectForKey:@"twitter"];
            if (twitterIdentity != nil) {
                NSString *twitterName = [twitterIdentity objectForKey:@"name"];
                if ((twitterName != nil) && ([twitterName length] > 0)) {
                    name = twitterName;
                }
                NSString *twitterSN = [twitterIdentity objectForKey:@"screen_name"];
                if ((twitterSN != nil) && ([twitterSN length] > 0)) {
                    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/users/show.json"];
                    
                    NSDictionary *params = [NSDictionary dictionaryWithObject:twitterSN
                                                                       forKey:@"screen_name"];
                    
                    TWRequest *request = [[TWRequest alloc] initWithURL:url
                                                             parameters:params
                                                          requestMethod:TWRequestMethodGET];
                    
                    [request performRequestWithHandler:
                     ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                         if (responseData) {
                             NSDictionary *user =
                             [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:NSJSONReadingAllowFragments
                                                               error:NULL];
                             
                             NSString *profileImageUrl = [user objectForKey:@"profile_image_url"];
                             
                             dispatch_async
                             (dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                 NSData *imageData =
                                 [NSData dataWithContentsOfURL:
                                  [NSURL URLWithString:profileImageUrl]];
                                 
                                 UIImage *image = [UIImage imageWithData:imageData];
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     cell.imageView.image = image;
                                 });
                             });
                         } else if (error) {
                             NSLog(@"HERE! %@", error);
                         }
                     }];
                }
            }
        }
    }

    cell.textLabel.text = name;
    cell.imageView.image  = [UIImage imageNamed:@"clear.png"];
    cell.pic.profileID = fbID;

    return cell;
}
@end
