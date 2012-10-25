//
//  WriteUpdateViewController.m
//  StatusShare
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import "WriteUpdateViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <KinveyKit/CLLocation+Kinvey.h>

#import "KinveyFriendsUpdate.h"
#import "UIColor+KinveyHelpers.h"

@interface WriteUpdateViewController ()
{
    UITextField *_activeField;
    float _kbHeight;
    NSArray* _sessionTimes;
    
}
@property (nonatomic, retain) id<KCSStore> updateStore;
@property (nonatomic, retain) UIImage* attachedImage;
@property (nonatomic, retain) CLLocationManager* locationManager;
@end

@implementation WriteUpdateViewController
//@synthesize bottomToolbar;
@synthesize scrollView;
@synthesize sessionTitle;
@synthesize sessionLeader;
@synthesize sessionTime;
@synthesize sessionDescription;
@synthesize mainView;
@synthesize postButton;
//@synthesize geoButtonItem;
@synthesize updateStore;
@synthesize attachedImage;
@synthesize locationManager;


- (void)viewDidLoad
{
    [super viewDidLoad];
    public = YES;
    
    //Kinvey use code: create a new collection with a linked data store
    // no KCSStoreKeyOfflineSaveDelegate is specified
    KCSCollection* collection = [KCSCollection collectionFromString:@"Updates" ofClass:[KinveyFriendsUpdate class]];
    self.updateStore = [KCSLinkedAppdataStore storeWithOptions:@{ KCSStoreKeyResource : collection, KCSStoreKeyCachePolicy : @(KCSCachePolicyBoth), KCSStoreKeyUniqueOfflineSaveIdentifier : @"WriteUpdateViewController" , KCSStoreKeyOfflineSaveDelegate : self }];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardUpdated:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [self registerForKeyboardNotifications];
    
    //Kinvey use code: watch for network reachability to change so we can update the UI make a post able to send. 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kKCSReachabilityChangedNotification object:nil];
    
    if ([CLLocationManager locationServicesEnabled]) {
        //set up the location manger
        self.locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self; //we don't actually care about updates since only the current loc is used
        [locationManager startUpdatingLocation];
    }
    
    sessionDescription.layer.cornerRadius = 8.0f;
    sessionDescription.clipsToBounds = YES;
    sessionDescription.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    sessionDescription.layer.borderWidth = 1.0;
    
    sessionTitle.delegate = self;
    sessionLeader.delegate = self;
    sessionTime.delegate = self;
    sessionDescription.delegate = self;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];

    [self.locationManager stopUpdatingLocation];
    
    [self setLocationManager:nil];
    [self setSessionTitle:nil];
    [self setMainView:nil];
//    [self setBottomToolbar:nil];
//    [self setBottomToolbar:nil];
    [self setPostButton:nil];
//    [self setGeoButtonItem:nil];
    [self setSessionLeader:nil];
    [self setSessionTime:nil];
    [self setSessionDescription:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.sessionTitle becomeFirstResponder];
    
    //Kinvey use code: only enable the post button if Kinvey is reachable
    self.postButton.enabled = [[[KCSClient sharedClient] networkReachability] isReachable];
    
//    self.geoButtonItem.enabled = [CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        NSLog(@"scroll to height");
        CGPoint scrollPoint = CGPointMake(0.0, 130.0);
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
    [self createPickerViewWithTag:textField.tag];
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
        [sessionTime becomeFirstResponder];
        
    }
//    else if (textField.tag == sessionTime.tag)
//    {
//        [sessionDescription becomeFirstResponder];
//        
//        CGPoint scrollPoint = CGPointMake(0.0, 130.0);
//        [scrollView setContentOffset:scrollPoint animated:YES];
//        
//    }
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
-(void)createPickerViewWithTag:(int)tag
{
    //create Picker Here
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    pickerView.tag = tag + 2;
    
    int row = 0;
    row = 0; // fix to match selected value
    [pickerView selectRow:row inComponent:0 animated:YES];
    [sessionTime setInputView:pickerView];
        
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 4;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    _sessionTimes = [[NSArray alloc] initWithObjects:
                     @"Session I (10:15AM - 11:15AM)",
                     @"Session II (11:30AM - 12:30PM)",
                     @"Session III (1:15PM - 2:15PM)",
                     @"Session IV (2:30PM - 3:30PM)",
                     nil];
    
    return [_sessionTimes objectAtIndex:row];

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    sessionTime.text = [_sessionTimes objectAtIndex:row];
    [sessionDescription becomeFirstResponder];
    
    CGPoint scrollPoint = CGPointMake(0.0, 130.0);
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
        KinveyFriendsUpdate* update = [[KinveyFriendsUpdate alloc] init];
        update.title = sessionTitle.text;
        update.userDate = [NSDate date];
        
        if (self.sessionLeader.text.length > 0)
        {
            update.leader = sessionLeader.text;
        }
        
        if (self.sessionTime.text.length > 0)
        {
            update.time = sessionTime.text;
        }
        
        if (self.sessionDescription.text.length > 0)
        {
            update.description = sessionDescription.text;
        }
        
        //remove below
        if (self.attachedImage != nil) {
            update.attachment = self.attachedImage;
        }
        if (!public) {
            if (!update.meta) {
                update.meta = [[KCSMetadata alloc] init];
            }
            [update.meta setGloballyReadable:NO];
        }
        if (location && [CLLocationManager locationServicesEnabled]) {
            CLLocation* l = [self.locationManager location];
            update.location = [l kinveyValue];
        }
        
        //Kinvey use code: add a new update to the updates collection
        [updateStore saveObject:update withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
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

//- (IBAction)takePicture:(id)sender 
//{
//    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
//    imagePicker.delegate = self;
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    } else {
//        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    }
//    
//    [self presentModalViewController:imagePicker animated:YES];
//}

#pragma mark - pictures

//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    self.attachedImage = nil;
//    [self dismissModalViewControllerAnimated:YES];
//}
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
//{
//    [self dismissModalViewControllerAnimated:YES];
//    self.attachedImage = image;
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        CGFloat scale = [self.view.window.screen scale];
//        CGSize size = CGSizeMake(24., 24.);
//        UIGraphicsBeginImageContextWithOptions(size, YES, scale);
//        CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationHigh);
//        [image drawInRect:CGRectMake(0., 0., size.width, size.height)];
//        UIImage* thumb = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        UIImageView* thumbView = [[UIImageView alloc] initWithImage:thumb];
//        thumbView.userInteractionEnabled = YES;
//        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithCustomView:thumbView];
//        button.target = self;
//        button.action = @selector(takePicture:);
////        NSMutableArray* oldItems = [NSMutableArray arrayWithArray:self.bottomToolbar.items];
////        [oldItems replaceObjectAtIndex:oldItems.count - 1 withObject:button];
////        [self.bottomToolbar setItems:oldItems animated:YES];
//    });
//}

//- (IBAction)togglePrivacy:(id)sender 
//{
//    public = !public;
//    UIBarButtonItem* item = sender;
//    [item setImage:[UIImage imageNamed:(public ? @"unlock" : @"lock")]];
//}
//
//- (IBAction)toggleGeolocation:(id)sender
//{
//    location = !location;
//    UIBarButtonItem* item = sender;
//    item.tintColor = location ? [[[UIColor greenColor] darkerColor] colorWithAlphaComponent:0.5]: nil;
//}

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
