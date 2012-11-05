//
//  AuthorViewController.m
//  StatusShare
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import "AuthorViewController.h"

#import "UIColor+KinveyHelpers.h"
#import "KinveyFriendsUpdate.h"
#import "GravatarStore.h"
#import "UpdateCell.h"
#import "KCSButton.h"

#import "AttendeesViewController.h"
#import "WriteUpdateViewController.h"

#define kAuthor @"_acl.creator"


@interface AuthorViewController () {
    @private
    KCSCachedStore* _updateStore;
    KCSButton *_attendBtn;
    KCSButton *_unattendBtn;
    KCSButton *_shareBtn;
    KCSButton *_editBtn;
    KCSButton *_deleteBtn;
}
@property (nonatomic) KCSGroup* grouping;
@property (nonatomic) NSString* name;
@end

@implementation AuthorViewController
@synthesize update, grouping, name;
- (void) commonInit
{
    KCSCollection* collection = [KCSCollection collectionFromString:@"Updates" ofClass:[KinveyFriendsUpdate class]];
    _updateStore = [KCSCachedStore storeWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:collection, KCSStoreKeyResource, [NSNumber numberWithInt:KCSCachePolicyBoth], KCSStoreKeyCachePolicy, nil]];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self =[super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) updateGravatar
{
//    KCSCollection* users = [[KCSClient sharedClient].currentUser userCollection];
//    KCSCachedStore* userStore = [KCSCachedStore storeWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:users, KCSStoreKeyResource, [NSNumber numberWithInt:KCSCachePolicyLocalFirst], KCSStoreKeyCachePolicy, nil]];
//    [userStore loadObjectWithID:self.author withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
//        if (objectsOrNil && objectsOrNil.count > 0) {
//            KCSUser* user = [objectsOrNil objectAtIndex:0];
//            self.name = user.username;
//            self.title = user.username;
//            
//            NSUInteger size = [[self.view.window screen]  scale] * 48.;
//            GravatarStore* store = [GravatarStore storeWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:size], GravatarStoreOptionSizeKey, nil]];
//            [store queryWithQuery:name withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
//                UIImage* avImage = [objectsOrNil objectAtIndex:0];
//                self.image = avImage;
//            } withProgressBlock:nil];
//        }
//    } withProgressBlock:nil];
}

- (void) updateCount
{
    [_updateStore group:[NSArray arrayWithObject:kAuthor] reduce:[KCSReduceFunction COUNT] condition:[KCSQuery query] completionBlock:^(KCSGroup *valuesOrNil, NSError *errorOrNil) {
        if (valuesOrNil != nil) {
            self.grouping = valuesOrNil;
            [self.tableView reloadData];
        }
    } progressBlock:nil];
}


-(void)loadData
{
    _sessionTitleLabel.text = update.title;
    _sessionLeaderLabel.text = update.leader;
    _sessionLocationLabel.text = update.location;
    _sessionTimeLabel.text = update.time;

    _sessionAttendeesLabel.text = [NSString stringWithFormat:@"%i", [update.attendees count]];

    _sessionDescriptionLabel.text = update.description;
    _sessionDescriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
    _sessionDescriptionLabel.numberOfLines = 0;
    _sessionDescriptionLabel.font = [UIFont fontWithName:@"Helvetica" size:13.0];
    _sessionDescriptionLabel.text = update.description;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Kinvey use code: watch for network reachability to change so we can update the UI make a post able to send.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kKCSReachabilityChangedNotification object:nil];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chalkboard.png"]];
    self.navigationItem.title = update.title;
    
    [self.navigationController setNavigationBarHidden:NO];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 270, 320, 115)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    
    KCSUser *user = [[KCSClient sharedClient] currentUser];
    
    _attendBtn = [[KCSButton alloc] initWithFrame:CGRectMake(20, 10, 280, 35)];
    [_attendBtn setTitle:@"I want to attend!" forState:UIControlStateNormal];
    [_attendBtn addTarget:self action:@selector(addMe:) forControlEvents:UIControlEventTouchUpInside];
    
    _unattendBtn = [[KCSButton alloc] initWithFrame:CGRectMake(20, 10, 280, 35) andColor:[UIColor orangeColor]];
    [_unattendBtn setTitle:@"Nevermind, I'm not attending..." forState:UIControlStateNormal];
    [_unattendBtn addTarget:self action:@selector(removeMe:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([update.attendees containsObject:user.kinveyObjectId])
    {
        [footerView addSubview:_unattendBtn];
    }
    else
    {
        [footerView addSubview:_attendBtn];
    }
    
    float editBtnY = 60;
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 6)
    {
        _shareBtn = [[KCSButton alloc] initWithFrame:CGRectMake(20, 60, 280, 35)];
        [_shareBtn setTitle:@"Tell my friends" forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:_shareBtn];
        editBtnY = 110;
    }
    
    if ([update.meta.creatorId isEqualToString:[user getValueForAttribute:@"_id"]])
    {
        _editBtn = [[KCSButton alloc] initWithFrame:CGRectMake(20, editBtnY, 280, 35)];
        [_editBtn setTitle:@"Edit this session" forState:UIControlStateNormal];
        [_editBtn addTarget:self action:@selector(editSession:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:_editBtn];
        
        _deleteBtn = [[KCSButton alloc] initWithFrame:CGRectMake(20, editBtnY + 50, 280, 35) andColor:[UIColor redColor].darkerColor];
        [_deleteBtn setTitle:@"Delete this session" forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteSession:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:_deleteBtn];
        
        [footerView setFrame:CGRectMake(0, 270, 320, 200)];
    }
    
    self.tableView.tableFooterView = footerView;
    
    // Simulate reachabilty changing on view load to set to correct state
    [self reachabilityChanged:nil];
}
- (void)viewDidUnload {
    _sessionTitleLabel = nil;
    _sessionLeaderLabel = nil;
    _sessionLocationLabel = nil;
    _sessionTimeLabel = nil;
    _sessionAttendeesLabel = nil;
    _sessionDescriptionLabel = nil;
    [super viewDidUnload];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
    [self updateGravatar];
    [self updateCount];
}

#pragma mark - Button methods

-(void)addMe:(id)sender
{
    if (update.attendees == nil)
    {
        update.attendees = [[NSMutableSet alloc] init];
    }
    [update.attendees addObject:[[KCSClient sharedClient].currentUser kinveyObjectId]];
    
    __block BOOL success;
    [_updateStore saveObject:update withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        if (errorOrNil != nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Looks like your RSVP failed..."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            
            [alert show];
            success = NO;
            [update.attendees removeObject:[[KCSClient sharedClient].currentUser kinveyObjectId]];
        }
        else
        {
            success = YES;
        }
    } withProgressBlock:nil];
    
    if (success)
    {
        [[sender superview] addSubview:_unattendBtn];
        [sender removeFromSuperview];
    }
    [self loadData];
}

- (void)removeMe:(id)sender
{
    KCSUser *user = [[KCSClient sharedClient] currentUser];
    __block BOOL success;
    
    if ([update.attendees containsObject:user.kinveyObjectId])
    {
        [update.attendees removeObject:user.kinveyObjectId];
        
        [_updateStore saveObject:update withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
            if (errorOrNil != nil)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                                message:@"Looks like something went wrong..."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                
                [alert show];
                success = NO;
                [update.attendees addObject:user.kinveyObjectId];
            }
            else
            {
                success = YES;
            }
        } withProgressBlock:nil];
    }
    
    if (success)
    {
        [[sender superview] addSubview:_attendBtn];
        [sender removeFromSuperview];
    }
    [self loadData];
    
}

- (void)share:(id)sender
{
    NSArray *activityItems = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"Check out the %@ session at @masstlc #uncon", update.title], nil];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeCopyToPasteboard];
    
    [self presentViewController:activityController
                       animated:YES
                     completion:nil];
}

- (void)editSession:(id)sender
{
    [self performSegueWithIdentifier:@"coverWithEdit" sender:sender];
    
}

- (void)deleteSession:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                    message:@"Do you want to delete this session and remove all of it attendees?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Delete", nil];
    alert.tag = 30;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 30) {
        NSLog(@"%i",buttonIndex);
        if (buttonIndex == 1) {
            [_updateStore removeObject:update withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
                if (errorOrNil != nil)
                {
                    //alert
                }
                else
                {
                    [self.updatesViewController removeUpdate:update];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } withProgressBlock:nil];
        }
    }
}

#pragma mark - network
- (void) reachabilityChanged:(NSNotification*) note
{
    BOOL network = [[[KCSClient sharedClient] networkReachability] isReachable];
    _unattendBtn.enabled = network;
    _attendBtn.enabled = network;
    _shareBtn.enabled = network;
    _editBtn.enabled = network;
    _deleteBtn.enabled = network;
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 20. + [update.description sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13.0]
                                               constrainedToSize:CGSizeMake(280., 2000.)
                                          lineBreakMode:UILineBreakModeWordWrap].height;
    }
    return 44.;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 4)
    {
        [self performSegueWithIdentifier:@"pushToAttendees" sender:tableView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[AttendeesViewController class]])
    {
        [segue.destinationViewController setAttendees:update.attendees];
    }
    else if ([segue.destinationViewController isKindOfClass:[WriteUpdateViewController class]])
    {
        [segue.destinationViewController setNewSession:NO];
        [segue.destinationViewController setUnconSession:update];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
