//
//  WriteUpdateViewController.h
//  StatusShare
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <KinveyKit/KinveyKit.h>

#import "KinveyFriendsUpdate.h"

@interface WriteUpdateViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, KCSOfflineSaveDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *sessionTitle;
@property (weak, nonatomic) IBOutlet UITextField *sessionLeader;
@property (weak, nonatomic) IBOutlet UITextField *sessionLocation;
@property (weak, nonatomic) IBOutlet UITextField *sessionTime;
@property (weak, nonatomic) IBOutlet UITextView *sessionDescription;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;

@property (nonatomic) KinveyFriendsUpdate* unconSession;
@property (nonatomic) BOOL newSession;


- (IBAction)cancel:(id)sender;
- (IBAction)post:(id)sender;


@end
