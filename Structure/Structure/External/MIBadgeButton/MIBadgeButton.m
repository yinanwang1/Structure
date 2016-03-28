//
//  MIBadgeButton.m
//  Elmenus
//
//  Created by Mustafa Ibrahim on 2/1/14.
//  Copyright (c) 2014 Mustafa Ibrahim. All rights reserved.
//

#import "MIBadgeButton.h"
#import <QuartzCore/QuartzCore.h>

@interface MIBadgeButton() {
    UITextView *calculationTextView;
    UILabel *badgeLabel;
}

@end

@implementation MIBadgeButton

+(id)buttonWithType:(UIButtonType)t {
    return [[MIBadgeButton alloc] init];
}

#pragma mark - Setters

- (void) setBadgeString:(NSString *)badgeString
{
    _badgeString = badgeString;
    [self setupBadgeViewWithString:badgeString];
}
- (void)setBadgeEdgeInsets:(UIEdgeInsets)badgeEdgeInsets
{
    _badgeEdgeInsets = badgeEdgeInsets;
    [self setupBadgeViewWithString:NSStringFromUIEdgeInsets(_badgeEdgeInsets)];
}

#pragma mark - Initializers

- (id) init
{
    if(self == [super init]) {
        self.roundLabel = NO;
        
        [self setupBadgeViewWithString:nil];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if(self == [super initWithCoder:aDecoder]) {
        self.roundLabel = NO;
        
        [self setupBadgeViewWithString:nil];
    }
    return self;
}

- (id) initWithFrame:(CGRect) frame withBadgeString:(NSString *)string
{
    if (self == [super initWithFrame:frame]) {
        self.roundLabel = NO;
        
        [self setupBadgeViewWithString:string];
    }
    return self;
}

- (id) initWithFrame:(CGRect) frame withBadgeString:(NSString *)string badgeInsets:(UIEdgeInsets)badgeInsets
{
    if (self == [super initWithFrame:frame]) {
        self.roundLabel = NO;
        
        self.badgeEdgeInsets = badgeInsets;
        [self setupBadgeViewWithString:string];
    }
    return self;
}

- (void) setupBadgeViewWithString:(NSString *)string
{
    if(!badgeLabel) {
        badgeLabel = [[UILabel alloc] init];
        [self setupBadgeStyle];
        [self addSubview:badgeLabel];
    }
    
    [badgeLabel setClipsToBounds:YES];
    [badgeLabel setText:string];
    
    CGSize badgeSize = [badgeLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, FLT_MAX)];
    badgeSize.width = badgeSize.width < 10 ? 15 : badgeSize.width + 5;

    if(self.roundLabel) {
        badgeSize.height = badgeSize.width;
    }
    
    int vertical = self.badgeEdgeInsets.top - self.badgeEdgeInsets.bottom;
    int horizontal = self.badgeEdgeInsets.left - self.badgeEdgeInsets.right;
    
    [badgeLabel setFrame:CGRectMake(self.bounds.size.width - 5 + horizontal, -(badgeSize.height / 2) - 5 + vertical, badgeSize.width, badgeSize.height)];
    
    badgeLabel.layer.cornerRadius = badgeSize.height*0.5;
    
    badgeLabel.hidden = string ? NO : YES;
}

- (void) setupBadgeStyle
{
    [badgeLabel setTextAlignment:NSTextAlignmentCenter];
    [badgeLabel setBackgroundColor:[UIColor redColor]];
    [badgeLabel setTextColor:[UIColor whiteColor]];
    badgeLabel.layer.cornerRadius = badgeLabel.font.lineHeight*0.5;
}

- (void)setLabelFont:(UIFont *)font {
    [badgeLabel setFont:font];
}

- (void)setLabelTextColor:(UIColor *)color {
    [badgeLabel setTextColor:color];
}

- (void)setLabelBackGroundColor:(UIColor *)color {
    [badgeLabel setBackgroundColor:color];
}

@end
