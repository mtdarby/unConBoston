//
//  UpdateCell.m
//  StatusShare
//
//  Copyright (c) 2012 Kinvey. All rights reserved.
//

#import "UpdateCell.h"

#import <QuartzCore/QuartzCore.h>

#import "KinveyFriendsUpdate.h"

#import "UIColor+KinveyHelpers.h"
#import "GravatarStore.h"

//#define kThumbnailSize 250.

@interface CellBgView : UIView

@end

@implementation CellBgView

- (void) drawRect:(CGRect)rect
{
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:rect];
    [[UIColor colorWithIntRed:172 green:172 blue:172] setStroke];
    [path setLineWidth:1.];
 
    [[UIColor whiteColor] setFill];
    [path fill];
    
    [path stroke];
}

@end

@interface UpdateCell ()
@end

@implementation UpdateCell
//@synthesize nameLabel, textLabel, timeLabel, avatar, thumbnailView, pinView;
@synthesize nameLabel, textLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
        CellBgView* bgView = [[CellBgView alloc] initWithFrame:CGRectMake(0., 0., 100., 100.)];
        bgView.autoresizesSubviews = YES;
        bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        bgView.clipsToBounds = YES;
        [self.contentView addSubview:bgView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8., 4., 100, 26.)];
        nameLabel.font = [UIFont boldSystemFontOfSize:14.];
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.numberOfLines = 0;
        nameLabel.lineBreakMode = UILineBreakModeWordWrap;

        [bgView addSubview:nameLabel];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(8., CGRectGetMaxY(nameLabel.frame) + 10., 100., 20.)];
        textLabel.textColor = [UIColor colorWithIntRed:64 green:64 blue:64];
        textLabel.font = [UIFont systemFontOfSize:14.];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [bgView addSubview:textLabel];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect rect = CGRectMake(10., 0., self.bounds.size.width - 20., self.bounds.size.height);
    nameLabel.superview.frame = rect;
    [textLabel sizeToFit];
}

- (void) setUpdate:(KinveyFriendsUpdate*)update
{
    self.nameLabel.text = update.title;
    self.textLabel.text = [NSString stringWithFormat:@"By: %@", update.leader];
    self.nameLabel.frame = CGRectMake(8., 4., self.nameLabel.frame.size.width, [update.title sizeWithFont:[UIFont boldSystemFontOfSize:14.]
                                                                                        constrainedToSize:CGSizeMake(280., 2000.)
                                                                                            lineBreakMode:UILineBreakModeWordWrap].height);
    self.textLabel.frame = CGRectMake(8., CGRectGetMaxY(nameLabel.frame) + 5., self.textLabel.frame.size.width, self.textLabel.frame.size.height);

    
    //Kinvey code usage: if a KCSLinkedAppdataStore is not used, then linked resources will be NSDictionaries of the image metadata rather than the UIImage itself
//    if (update.attachment != nil && [update.attachment isKindOfClass:[UIImage class]]) {
//        self.thumbnailView.image = update.attachment;
//    } else {
//        self.thumbnailView.image = nil;
//    }
    
//    NSDate* date = update.userDate;
//    NSTimeInterval since = [[NSDate date] timeIntervalSinceDate:date];
//    NSString* dateFormat = @"";
//    if (since < 60) {
//        dateFormat = @"now";
//    } else if (since < 60 * 60) {
//        dateFormat = [NSString stringWithFormat:@"%0.fm", since / 60];
//    } else if ( since < 60 * 60 * 24) {
//        dateFormat = [NSString stringWithFormat:@"%0.fh", since / (60 * 60)];
//    } else {
//        double days = since / (60 * 60 * 24);
//        dateFormat = [NSString stringWithFormat:@"%0.fd", days];
//    }
//    self.timeLabel.text = dateFormat;
//    self.pinView.hidden = update.location == nil;
    
//    KCSCollection* users = [[KCSClient sharedClient].currentUser userCollection];
//    KCSCachedStore* userStore = [KCSCachedStore storeWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:users, KCSStoreKeyResource, [NSNumber numberWithInt:KCSCachePolicyLocalFirst], KCSStoreKeyCachePolicy, nil]];
//    [userStore loadObjectWithID:[update.meta creatorId] withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
//        if (objectsOrNil && objectsOrNil.count > 0) {
//            KCSUser* user = [objectsOrNil objectAtIndex:0];
//            NSString* name = user.username;
//            NSDictionary *socialIdentity = [user getValueForAttribute:@"_socialIdentity"];
//            if (socialIdentity != nil) {
//                NSDictionary *facebookIdentity = [socialIdentity objectForKey:@"facebook"];
//                if (facebookIdentity != nil) {
//                    NSString* facebookName = [facebookIdentity objectForKey:@"name"];
//                    if ((facebookName != nil) && ([facebookName length] > 0)) {
//                        name = facebookName;
//                    }
//                }
//            }
    
    
//            NSUInteger size = [[UIScreen mainScreen]  scale] * kAvatarSize;
//            GravatarStore* store = [GravatarStore storeWithOptions:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:size], GravatarStoreOptionSizeKey, nil]];
//            [store queryWithQuery:name withCompletionBlock:^(NSArray *objectsOrNil, NSError *errorOrNil) {
//                UIImage* image = [objectsOrNil objectAtIndex:0];
//                self.avatar.image = image;
//            } withProgressBlock:nil];
//        }
//    } withProgressBlock:nil];
}

@end
