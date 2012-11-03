//
//  WriteUpdateViewController.m
//  StatusShare
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import "WriteUpdateViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <KinveyKit/CLLocation+Kinvey.h>


#import "UIColor+KinveyHelpers.h"

@interface WriteUpdateViewController ()
{
    UITextField *_activeField;
    float _kbHeight;
    NSArray* _sessionTimes;
    
}
@property (nonatomic, retain) id<KCSStore> unconSessionStore;
@end

@implementation WriteUpdateViewController

@synthesize scrollView;
@synthesize sessionTitle;
@synthesize sessionLeader;
@synthesize sessionLocation;
@synthesize sessionTime;
@synthesize sessionDescription;
@synthesize mainView;
@synthesize postButton;
@synthesize unconSessionStore;

@synthesize unconSession;
@synthesize newSession;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Kinvey use code: create a new collection with a linked data store
    // no KCSStoreKeyOfflineSaveDelegate is specified
    KCSCollection* collection = [KCSCollection collectionFromString:@"Updates" ofClass:[KinveyFriendsUpdate class]];
    self.unconSessionStore = [KCSLinkedAppdataStore storeWithOptions:@{ KCSStoreKeyResource : collection, KCSStoreKeyCachePolicy : @(KCSCachePolicyBoth), KCSStoreKeyUniqueOfflineSaveIdentifier : @"WriteUpdateViewController" , KCSStoreKeyOfflineSaveDelegate : self }];

    [self registerForKeyboardNotifications];
    
    //Kinvey use code: watch for network reachability to change so we can update the UI make a post able to send. 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kKCSReachabilityChangedNotification object:nil];
    
    sessionDescription.layer.cornerRadius = 8.0f;
    sessionDescription.clipsToBounds = YES;
    sessionDescription.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    sessionDescription.layer.borderWidth = 1.0;
    
    sessionTitle.delegate = self;
    sessionLeader.delegate = self;
    sessionLocation.delegate = self;
    sessionTime.delegate = self;
    sessionDescription.delegate = self;
    
    if (unconSession == nil) {
        unconSession = [[KinveyFriendsUpdate alloc] init];
    } else {
        [self loadData];
    }
    
    _sessionTimes = [[NSArray alloc] initWithObjects:
                     @"Session I (10:15AM - 11:15AM)",
                     @"Session II (11:30AM - 12:30PM)",
                     @"Session III (1:15PM - 2:15PM)",
                     @"Session IV (2:30PM - 3:30PM)",
                     nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];

    [super viewDidUnload];
    
    [self setSessionTitle:nil];
    [self setMainView:nil];
    [self setPostButton:nil];
    [self setSessionLeader:nil];
    [self setSessionLocation:nil];
    [self setSessionTime:nil];
    [self setSessionDescription:nil];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    if (newSession) {
        [self.sessionTitle becomeFirstResponder];
    }
    
    //Kinvey use code: only enable the post button if Kinvey is reachable
    self.postButton.enabled = [[[KCSClient sharedClient] networkReachability] isReachable];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadData
{
    sessionTitle.text = unconSession.title;
    sessionLeader.text = unconSession.leader;
    sessionLocation.text = unconSession.location;
    sessionTime.text = unconSession.time;
    sessionDescription.text = unconSession.description;
}

#pragma mark - network
- (void) reachabilityChanged:(NSNotification*) note
{
    self.postButton.enabled = [[[KCSClient sharedClient] networkReachability] isReachable];    
}

#pragma mark - Keyboard
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    _kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, _kbHeight, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    if (_activeField == nil) {
        CGPoint scrollPoint = CGPointMake(0.0, 180.0);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Text Field
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeField = textField;
    [self createPickerView];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _activeField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == sessionTitle.tag)
    {
        [sessionLeader becomeFirstResponder];
    }
    else if (textField.tag == sessionLeader.tag)
    {
        [sessionLocation becomeFirstResponder];
        
    }
    else if (textField.tag == sessionLocation.tag)
    {
        [sessionTime becomeFirstResponder];
    }

    return YES;
}

#pragma mark - Text View
- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"])
    {
        // Dismiss keyboard
        [textView resignFirstResponder];
        
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - Picker View
-(void)createPickerView
{
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    int row = 0;
    if (sessionTime.text.length != 0) {
        row = [_sessionTimes indexOfObject:sessionTime.text];
    }
    if (row != NSNotFound) {
        [pickerView selectRow:row inComponent:0 animated:YES];
    } else {
        [pickerView selectRow:0 inComponent:0 animated:YES];
    }
    [sessionTime setInputView:pickerView];
        
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 4;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    return [_sessionTimes objectAtIndex:row];

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    sessionTime.text = [_sessionTimes objectAtIndex:row];
    [sessionDescription becomeFirstResponder];
    
    CGPoint scrollPoint = CGPointMake(0.0, 180.0);
    [scrollView setContentOffset:scrollPoint animated:YES];
}


#pragma mark - Actions
- (IBAction)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)post:(id)sender
{
    if (self.sessionTitle.text.length > 0)
    {
        unconSession.title = sessionTitle.text;
        unconSession.userDate = [NSDate date];
        
        if (self.sessionLeader.text.length > 0)
        {
            unconSession.leader = sessionLeader.text;
        }
        
        if (self.sessionLocation.text.length > 0)
        {
            unconSession.location = sessionLocation.text;
        }
        
        if (self.sessionTime.text.length > 0)
        {
            unconSession.time = sessionTime.text;
        }
        
        if (self.sessionDescription.text.length > 0)
        {
            unconSession.description = sessionDescription.text;
        }
        
        NSMutableSet* attendees = [[NSMutableSet alloc] init];
        unconSession.attendees = attendees;

        [unconSessionStore saveObject:unconSession withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
            if (errorOrNil == nil) {
                sessionTitle.text = @"";
                [self cancel:nil];
            } else {
                BOOL wasNetworkError = [errorOrNil domain] == KCSNetworkErrorDomain;
                NSString* title = wasNetworkError ? NSLocalizedString(@"There was a netowrk error.", @"network error title"): NSLocalizedString(@"An error occurred.", @"Generic error message");
                NSString* message = wasNetworkError ? NSLocalizedString(@"Please wait a few minutes and try again.", @"try again error message") : [errorOrNil localizedDescription];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:message                                                           delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
                [alert show];
            }
        } withProgressBlock:nil];
    
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Did you forget something?"
                                  message:@"Looks like you did not enter a title for your session."
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        
        [alertView show];

    }
    
}

#pragma mark - Offline Save Delegate

// don't save any queued saves that older than a day
- (BOOL) shouldSave:(id<KCSPersistable>)entity lastSaveTime:(NSDate *)timeSaved
{
    NSTimeInterval oneDayAgo = 60 /* sec/min */ * 60 /* min/hr */ * 24 /* hr/day*/; //because NSTimeInterval in seconds
    if ([timeSaved timeIntervalSinceNow] < oneDayAgo) {
        return NO;
    } else {
        return YES;
    }
}
@end
