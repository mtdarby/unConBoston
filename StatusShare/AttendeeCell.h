//
//  AttendeeCell.h
//  StatusShare
//
//  Created by Michelle Darby on 10/27/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AttendeeCell : UITableViewCell
{
    NSString *_attendeeId;
}
@property (nonatomic, retain) FBProfilePictureView *pic;

- (void) setAttendee:(NSString*)attendeeId;

@end
