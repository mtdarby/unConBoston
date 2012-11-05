//
//  LoginViewContoller.m
//  StatusShare
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import "LoginViewContoller.h"

#import <KinveyKit/KinveyKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface LoginViewContoller()
@end

@implementation LoginViewContoller
@synthesize facebookLoginButton;
@synthesize twitterLoginButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [self setFacebookLoginButton:nil];
    [self setTwitterLoginButton:nil];
    [super viewDidUnload];
}


- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    
    ///Kinvey-Use code: if the user is already logged in, go straight to the main part of the app via segue
    if ([KCSUser hasSavedCredentials] == YES) {
        [self performSegueWithIdentifier:@"toTable" sender:self];
    }
}

#pragma mark - TextField Stuff
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    [self validate];
//    return NO;
//}
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    [self validate];
//    return YES;
//}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [self validate];
//    if (textField == self.userNameTextField) {
//        [self.passwordTextField becomeFirstResponder];
//    } else {
//        [textField resignFirstResponder];
//        if (self.loginButton.enabled) {
//            [self login:self.loginButton];
//        }
//    }
//    return YES;
//}
//

#pragma mark - Actions
//- (void) disableButtons:(NSString*) message;
//{
//    self.loginButton.enabled = NO;
//    self.createAccountButton.enabled = NO; 
//    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.labelText = message;
//}

//- (void) reenableButtons
//{
//    [self validate];
//    self.createAccountButton.enabled = YES;
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//}

- (void) handeLogin:(NSError*)errorOrNil
{
    if (errorOrNil != nil) {
        BOOL wasUserError = [errorOrNil domain] == KCSUserErrorDomain;
        NSString* title = wasUserError ? NSLocalizedString(@"Invalid Credentials", @"credentials error title") : NSLocalizedString(@"An error occurred.", @"Generic error message");
        NSString* message = wasUserError ? NSLocalizedString(@"Wrong username or password. Please check and try again.", @"credentials error message") : [errorOrNil localizedDescription];
        
        NSString *internetString= [[[errorOrNil userInfo] objectForKey:NSUnderlyingErrorKey] localizedDescription];
        NSString *internetOffline = @"The internet connection appears to be offline";
        NSRange isRange = [internetString rangeOfString:internetOffline options:NSCaseInsensitiveSearch];
        if(isRange.location == 0) {
            message = internetOffline;
            title = @"No Connection";
        } else {
            NSRange isSpacedRange = [internetString rangeOfString:internetOffline options:NSCaseInsensitiveSearch];
            if(isSpacedRange.location != NSNotFound) {
                message = internetOffline;
                title = @"No Connection";
            }
        }
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message                                                           delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        [self performSegueWithIdentifier:@"toTable" sender:self];
    }

}

//- (IBAction)login:(id)sender
//{
//    [self disableButtons:NSLocalizedString(@"Logging in", @"Logging In Message")];
//    
//    ///Kinvey-Use code: login with the typed credentials
//    [KCSUser loginWithUsername:self.userNameTextField.text password:self.passwordTextField.text withCompletionBlock:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
//        [self handeLogin:errorOrNil];
//    }];
//}

- (IBAction)loginWithFacebook:(id)sender
{
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.session = [[FBSession alloc] initWithAppID:@"293567604077027"
                                        permissions:nil
                                    urlSchemeSuffix:nil
                                 tokenCacheStrategy:nil];
    FBSession* session = [delegate session];

    // if the session isn't open, let's open it now and present the login UX to the user
    if (!session.isOpen) {
        [session openWithCompletionHandler:^(FBSession *session,
                                             FBSessionState status,
                                             NSError *error) {
            if (status == FBSessionStateOpen) {
                NSString* accessToken = session.accessToken;
                [KCSUser loginWithFacebookAccessToken:accessToken withCompletionBlock:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
                    [self handeLogin:errorOrNil];
                }];
            }
        }];
    }
}

- (IBAction)loginWithTwitter:(id)sender
{
    
    [KCSUser getAccessDictionaryFromTwitterFromPrimaryAccount:^(NSDictionary *accessDictOrNil, NSError *errorOrNil) {
        if (accessDictOrNil) {
            [KCSUser loginWithWithSocialIdentity:KCSSocialIDTwitter
                                accessDictionary:accessDictOrNil
                             withCompletionBlock:^(KCSUser *user, NSError *errorOrNil, KCSUserActionResult result) {
                                 if (errorOrNil) {
                                     NSLog(@"%@", errorOrNil);
                                 }
                                 [self handeLogin:errorOrNil];
                             }];
        }
        NSLog(@"%@", errorOrNil);
        if (errorOrNil != nil) {
            [self handeLogin:errorOrNil];
        }
    }];
    NSLog(@"I tried to login with Twitter");
}

//      
//- (IBAction)createAccount:(id)sender
//{
//    [self performSegueWithIdentifier:@"pushToCreateAccount" sender:self];
//}
@end
