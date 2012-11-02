//
//  UpdatesViewController.m
//  StatusShare
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import "UpdatesViewController.h"
#import <KinveyKit/KinveyKit.h>

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

#import "KinveyFriendsUpdate.h"
#import "UpdateCell.h"

#import "AuthorViewController.h"
#import "WriteUpdateViewController.h"

#import "GravatarStore.h"
#import "UIColor+KinveyHelpers.h"

@implementation UpdatesCell
@end

@interface UpdatesViewController ()
@property (nonatomic, retain) NSArray* updates;
//@property (nonatomic, retain) NSArray* session1;
//@property (nonatomic, retain) NSArray* session2;
//@property (nonatomic, retain) NSArray* session3;
//@property (nonatomic, retain) NSArray* session4;
@property (nonatomic, retain) NSMutableArray* sessions;
@property (nonatomic, retain) KCSCachedStore* updateStore;
@property (nonatomic, retain) NSArray* sessionTimes;

- (void) updateList;
@end

@implementation UpdatesViewController
@synthesize updates;
@synthesize updateStore;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set backgound view
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chalkboard.png"]];
    
    
    KCSCollection* collection = [KCSCollection collectionFromString:@"Updates" ofClass:[KinveyFriendsUpdate class]];
    self.updateStore = [KCSLinkedAppdataStore storeWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:collection, KCSStoreKeyResource, [NSNumber numberWithInt:KCSCachePolicyBoth], KCSStoreKeyCachePolicy, nil]];
    
    self.sessions = [[NSMutableArray alloc] initWithCapacity:4];
    for (NSInteger i = 0; i < 4; ++i)
    {
        [self.sessions addObject:[NSMutableArray array]];
    }
    
    self.sessionTimes = @[@"Session I (10:15AM - 11:15AM)", @"Session II (11:30AM - 12:30PM)", @"Session III (1:15PM - 2:15PM)",@"Session IV (2:30PM - 3:30PM)"];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithIntRed:110 green:159 blue:52];
    self.navigationItem.title = @"Sessions";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(startCompose:)];
    
    UIBarButtonItem* logoutButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Logout", @"Logout button") style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
    [self updateList];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (KinveyFriendsUpdate*) updateAtIndex:(NSUInteger)index
{
    return [self.updates objectAtIndex:index];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[AuthorViewController class]]) {
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        KinveyFriendsUpdate* update = [[self.sessions objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

        [segue.destinationViewController setUpdate:update];
        [segue.destinationViewController setUpdatesViewController:self];
    }
    else if ([segue.destinationViewController isKindOfClass:[WriteUpdateViewController class]])
    {
        [segue.destinationViewController setNewSession:YES];
//        [segue.destinationViewController setUnconSession:[[KinveyFriendsUpdate alloc] init]];
//        [segue.destinationViewController setUnconsession:[[KinveyFriendsUpdate alloc] init]];
    }
}
- (void)removeUpdate:(KinveyFriendsUpdate *)update
{
    NSUInteger time = [self.sessionTimes indexOfObject:update.time];
    [self.sessions[time] removeObject:update];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{    
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Session I (10:15AM - 11:15AM)";
            break;
            
        case 1:
            return @"Session II (11:30AM - 12:30PM)";
            break;
            
        case 2:
            return @"Session III (1:15PM - 2:15PM)";
            break;

        case 3:
            return @"Session IV (2:30PM - 3:30PM)";
            break;
            
        default:
            break;
    }
    return @"Sessions";
}

//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
//    if (section == 1)
//        [headerView setBackgroundColor:[UIColor redColor]];
//    else
//        [headerView setBackgroundColor:[UIColor clearColor]];
//    return headerView;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    if ([self.sessions objectAtIndex:section] != [NSNull null])
    {
        NSArray *sessionGroup = [self.sessions objectAtIndex:section];
        rows = sessionGroup.count;
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KinveyFriendsUpdate *session = self.sessions[indexPath.section][indexPath.row];
    return 40. + [session.title sizeWithFont:[UIFont boldSystemFontOfSize:14.]
                                constrainedToSize:CGSizeMake(280., 2000.)
                                    lineBreakMode:UILineBreakModeWordWrap].height;
//    return 64.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"Cell";
    UpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell)
    {
        cell = [[UpdateCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    KinveyFriendsUpdate *update = [[self.sessions objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell setUpdate:update];
   
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"segueToAuthor" sender:tableView];
}

#pragma mark - Text Field
- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)refresh
{
    [self updateList];
}

#pragma mark - Compose
- (void) startCompose:(id)sender
{
    [self performSegueWithIdentifier:@"coverWithWrite" sender:sender];
}

#pragma mark - Kinvey Methods

- (void) updateList
{
    KCSQuerySortModifier* sortByTitle = [[KCSQuerySortModifier alloc] initWithField:@"title" inDirection:kKCSAscending];

    
    KCSQuery* query1 = [KCSQuery queryOnField:@"time" withExactMatchForValue:@"Session I (10:15AM - 11:15AM)"];
    [query1 addSortModifier:sortByTitle]; //sort the return by the date field
    [updateStore queryWithQuery:query1 withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        if (objectsOrNil) {
            [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
            [self.sessions[0] setArray:objectsOrNil];
            [self.tableView reloadData];
        }
    } withProgressBlock:nil];
    
    KCSQuery* query2 = [KCSQuery queryOnField:@"time" withExactMatchForValue:@"Session II (11:30AM - 12:30PM)"];
    [query2 addSortModifier:sortByTitle];
    [updateStore queryWithQuery:query2 withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        if (objectsOrNil) {
            [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
            [self.sessions replaceObjectAtIndex:1 withObject:objectsOrNil];
            [self.tableView reloadData];
        }
    } withProgressBlock:nil];
    
    KCSQuery* query3 = [KCSQuery queryOnField:@"time" withExactMatchForValue:@"Session III (1:15PM - 2:15PM)"];
    [query3 addSortModifier:sortByTitle];
    [updateStore queryWithQuery:query3 withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        if (objectsOrNil) {
            [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
            [self.sessions replaceObjectAtIndex:2 withObject:objectsOrNil];
            [self.tableView reloadData];
        }
    } withProgressBlock:nil];
    
    KCSQuery* query4 = [KCSQuery queryOnField:@"time" withExactMatchForValue:@"Session IV (2:30PM - 3:30PM)"];
    [query4 addSortModifier:sortByTitle];
    [updateStore queryWithQuery:query4 withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        if (objectsOrNil) {
            [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
            [self.sessions replaceObjectAtIndex:3 withObject:objectsOrNil];
            [self.tableView reloadData];
        }
    } withProgressBlock:nil];
}

- (void) logout
{
    self.updates = [NSArray array]; //clear array so that the previous user's data is cached if a different user logins in immediately
    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    FBSession* session = [delegate session];
    
    [session closeAndClearTokenInformation];
    delegate.session = nil;
    
    [[[KCSClient sharedClient] currentUser] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
