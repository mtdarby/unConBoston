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

#import "AppDelegate.h"
#import "KinveyFriendsUpdate.h"
#import "AttendeeCell.h"

@interface AttendeesViewController ()
{
//    KCSCachedStore* _userStore;
    NSString* _name;
    NSArray *_names;
}

@end

@implementation AttendeesViewController
@synthesize attendees;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Attendees";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    [self.tableView reloadData];
//    __block NSString *name = @"Michelle";
    
    _names = @[];
    
    KCSCollection* users = [[KCSClient sharedClient].currentUser userCollection];
    KCSCachedStore* userStore = [KCSCachedStore storeWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:users, KCSStoreKeyResource, [NSNumber numberWithInt:KCSCachePolicyLocalFirst], KCSStoreKeyCachePolicy, nil]];
    
    //   KCSQuery* query1 = [KCSQuery queryOnField:@"_id" withExactMatchForValue:@"508968b5fb8003a32b000005"];
    [userStore loadObjectWithID:[attendees allObjects]  withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
        if (objectsOrNil) {
//            [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
//            [self.sessions replaceObjectAtIndex:0 withObject:objectsOrNil];
//            [self.tableView reloadData];
            _names = objectsOrNil;
        }
        [_tableview reloadData];
//        name = @"Darby";
    } withProgressBlock:nil];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self.tableView reloadData];
    [_tableview reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

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
//    AttendeeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//    if (!cell)
//    {
//        cell = [[AttendeeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//        [cell setUserInteractionEnabled:NO];
//    }
    
//    [cell setAttendee:@"508968b5fb8003a32b000005"];
    
    AttendeeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        cell = [[AttendeeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//        [cell setUserInteractionEnabled:NO];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    KCSUser *user = [_names objectAtIndex:indexPath.row];
    NSString *name = user.username;
    NSString *fbID = @"";
    NSDictionary *socialIdentity = [user getValueForAttribute:@"_socialIdentity"];
    if (socialIdentity != nil) {
        NSDictionary *facebookIdentity = [socialIdentity objectForKey:@"facebook"];
        if (facebookIdentity != nil) {
            NSString* facebookName = [facebookIdentity objectForKey:@"name"];
            if ((facebookName != nil) && ([facebookName length] > 0)) {
                name = facebookName;
            }
            NSString *facebookID = [facebookIdentity objectForKey:@"id"];
            if ((facebookID != nil) && ([facebookID length] > 0)) {
                fbID = facebookID;
            }
        }
    }

    cell.textLabel.text = name;
    cell.imageView.image  = [UIImage imageNamed:@"clear.png"];
    cell.pic.profileID = fbID;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    [_tableview reloadData];
}

- (void)viewDidUnload {
    _tableview = nil;
    [super viewDidUnload];
}
@end
