//
//  MIBadgeButton.h
//  Elmenus
//
//  Created by Mustafa Ibrahim on 2/1/14.
//  Copyright (c) 2014 Mustafa Ibrahim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MIBadgeButton : UIButton

@property (nonatomic, strong) NSString *badgeString;
@property (nonatomic) UIEdgeInsets badgeEdgeInsets;
@property (nonatomic, assign) BOOL roundLabel;

- (void)setLabelFont:(UIFont *)font;
- (void)setLabelTextColor:(UIColor *)color;
- (void)setLabelBackGroundColor:(UIColor *)color;

@end
