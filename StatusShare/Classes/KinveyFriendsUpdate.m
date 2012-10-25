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
@synthesize time = _time;
@synthesize description = _description;
@synthesize kinveyId = _kinveyId;
@synthesize userDate = _userDate;
@synthesize attachment = _attachment;
@synthesize meta = _meta;
@synthesize location = _location;

// Kinvey code use: any "KCSPersistable" has to implement this mapping method
- (NSDictionary *)hostToKinveyPropertyMapping
{
    return @{
    @"title"      : @"title",
    @"leader"     : @"leader",
    @"time"       : @"time",
    @"description": @"description",
    @"userDate"   : @"userDate",
    @"attachment" : @"attachment",
    @"meta"       : KCSEntityKeyMetadata,
    @"kinveyId"   : KCSEntityKeyId,
    @"location"   : KCSEntityKeyGeolocation,
    };
}
@end
