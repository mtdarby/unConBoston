//
//  AppDelegate.m
//  StatusShare
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import "AppDelegate.h"
#import <KinveyKit/KinveyKit.h>

@implementation AppDelegate
@synthesize session;
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Kinvey use code: You'll need to create an app on the backend and initialize it here:
    //http://docs.kinvey.com/ios-developers-guide.html#Initializing_Programmatically
    
//    NSDictionary *options = @{ KCS_PUSH_IS_ENABLED_KEY : @"YES",
//    KCS_PUSH_KEY_KEY : @"2l-5BkPkSe6fkf2IHeUbyg",
//    KCS_PUSH_SECRET_KEY : @"4MV50jGcQl-ik0B0TWjd7Q",
//    KCS_PUSH_MODE_KEY : KCS_PUSH_DEBUG,
//    KCS_TWITTER_CLIENT_KEY : @"QTyGt9aQpeZLKJoTauRjnw",
//    KCS_TWITTER_CLIENT_SECRET : @"yUd8JGhUXQNUlHfZOFNaKpmYJcwAC3vJtbJHNarINY"};
    
    NSDictionary *options = @{
    KCS_TWITTER_CLIENT_KEY : @"QTyGt9aQpeZLKJoTauRjnw",
    KCS_TWITTER_CLIENT_SECRET : @"yUd8JGhUXQNUlHfZOFNaKpmYJcwAC3vJtbJHNarINY"};
    
    (void) [[KCSClient sharedClient] initializeKinveyServiceForAppKey:@"kid_PPnCuemfeJ"
                                                        withAppSecret:@"9f99a4ff97764f8eb18e2d3eb3a1457f" 
                                                         usingOptions:options];
    
    NSError *error = nil;
    BOOL setUp = [[KCSPush sharedPush] onLoadHelper:options error:&error];
    //TODO: handle error if setUp == NO

    return YES;
}

#pragma - mark Push Methods
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[KCSPush sharedPush] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    // Additional registration goes here (if neeeded)
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[KCSPush sharedPush] application:application didReceiveRemoteNotification:userInfo];
    // Additional push notification handling code should be performed here
}


#pragma - mark Other Methods
// FBSample logic
// The native facebook application transitions back to an authenticating application when the user
// chooses to either log in, or cancel. The url passed to this method contains the token in the
// case of a successful login. By passing the url to the handleOpenURL method of a session object
// the session object can parse the URL, and capture the token for use by the rest of the authenticating
// application; the return value of handleOpenURL indicates whether or not the URL was handled by the
// session object, and does not reflect whether or not the login was successful; the session object's
// state, as well as its arguments passed to the state completion handler indicate whether the login
// was successful; note that if the session is nil or closed when handleOpenURL is called, the expression
// will be boolean NO, meaning the URL was not handled by the authenticating application
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [self.session handleOpenURL:url];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[KCSPush sharedPush] onUnloadHelper];
}

@end
