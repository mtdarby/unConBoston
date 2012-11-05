//
//  LoginViewContoller.h
//  StatusShare
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormViewController.h"

@interface LoginViewContoller : FormViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *facebookLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterLoginButton;

- (IBAction)loginWithFacebook:(id)sender;
- (IBAction)loginWithTwitter:(id)sender;

@end
