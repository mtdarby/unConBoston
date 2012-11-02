//
//  AttendeeCell.m
//  StatusShare
//
//  Created by Michelle Darby on 10/27/12.
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import "AttendeeCell.h"
#import <KinveyKit/KinveyKit.h>

@implementation AttendeeCell
@synthesize pic;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        pic = [[FBProfilePictureView alloc] init];
        [self.contentView addSubview:pic];        
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.pic.frame = self.imageView.frame;
}


@end
