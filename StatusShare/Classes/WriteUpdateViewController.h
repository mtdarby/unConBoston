//
//  WriteUpdateViewController.h
//  StatusShare
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <KinveyKit/KinveyKit.h>

@interface WriteUpdateViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, KCSOfflineSaveDelegate> {
    
    BOOL public;
    BOOL location;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *sessionTitle;
@property (weak, nonatomic) IBOutlet UITextField *sessionLeader;
@property (weak, nonatomic) IBOutlet UITextField *sessionTime;
@property (weak, nonatomic) IBOutlet UITextView *sessionDescription;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;

//@property (weak, nonatomic) IBOutlet UIBarButtonItem *geoButtonItem;


- (IBAction)cancel:(id)sender;
- (IBAction)post:(id)sender;
//- (IBAction)takePicture:(id)sender;
//@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
//- (IBAction)togglePrivacy:(id)sender;
//- (IBAction)toggleGeolocation:(id)sender;


@end
