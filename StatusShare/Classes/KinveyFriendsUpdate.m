//
//  KinveyFriendsUpdate.m
//  StatusShare
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import "KinveyFriendsUpdate.h"

@implementation KinveyFriendsUpdate
@synthesize title = _title;
@synthesize leader = _leader;
@synthesize location = _location;
@synthesize time = _time;
@synthesize description = _description;
@synthesize kinveyId = _kinveyId;
@synthesize userDate = _userDate;
@synthesize attachment = _attachment;
@synthesize meta = _meta;
@synthesize attendees = _attendees;

// Kinvey code use: any "KCSPersistable" has to implement this mapping method
- (NSDictionary *)hostToKinveyPropertyMapping
{
    return @{
    @"title"      : @"title",
    @"leader"     : @"leader",
    @"location"       : @"location",
    @"time"       : @"time",
    @"description": @"description",
    @"attendees"  : @"attendees",
    @"userDate"   : @"userDate",
    @"attachment" : @"attachment",
    @"meta"       : KCSEntityKeyMetadata,
    @"kinveyId"   : KCSEntityKeyId,
    };
}
@end
