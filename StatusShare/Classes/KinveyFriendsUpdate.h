//
//  KinveyFriendsUpdate.h
//  StatusShare
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <KinveyKit/KinveyKit.h>

/** This class represents an indivual post to the service */
@interface KinveyFriendsUpdate : NSObject <KCSPersistable>

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* leader;
@property (nonatomic, retain) NSString* location;
@property (nonatomic, retain) NSString* time;
@property (nonatomic, retain) NSString* description;

@property (nonatomic, retain) NSString* kinveyId;
@property (nonatomic, retain) NSDate* userDate;
@property (nonatomic, retain) UIImage* attachment;
@property (nonatomic, retain) KCSMetadata* meta;
@property (nonatomic, retain) NSMutableSet* attendees;

@end
