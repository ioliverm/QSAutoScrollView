//
//  QSAutoScrollView.h
//  Ride
//
//  Created by Ivan Oliver Martínez on 25/10/13.
//  Copyright (c) 2013 Ride. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QSAutoScrollViewDelegate <UIScrollViewDelegate>

@optional

- (void)hideKeyboardForTextView:(UIView *)textView;
- (BOOL)shouldAutoScrollForTextView:(UIView *)textView;

@end

@interface QSAutoScrollView : UIScrollView

@property (nonatomic, weak) id<QSAutoScrollViewDelegate>delegate;

- (void)textViewActivated:(UIView *)textView;
- (void)textViewDeactivated:(UIView *)textView;

@end
