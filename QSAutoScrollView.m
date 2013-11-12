//
//  QSAutoScrollView.m
//  QuietSoft
//
//  Created by Ivan Oliver Martínez on 25/10/13.
//  Copyright (c) 2013 Quiet Soft. All rights reserved.
//

#import "QSAutoScrollView.h"

static CGFloat const contentSizeBottomOffset = 10.0f;

@interface QSAutoScrollView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIGestureRecognizer *tapGestureRegognizer;
@property (nonatomic, weak) UIView *activeTextView;
@property (getter = isKeyboardShown) BOOL keyboardShown;
@property (nonatomic, assign) CGRect keyboardRect;
@property (nonatomic, assign) CGSize originalContentSize;
@property (nonatomic, assign) BOOL contentSizeSaved;
@property (nonatomic, assign) NSTimeInterval keyboardAnimationTimeInterval;

@end

@implementation QSAutoScrollView

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self configure];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        [self configure];
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardDidShowNotification
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillChangeFrameNotification
												  object:nil];
}

- (void)configure
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    _tapGestureRegognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(hideKeyboard:)];
    [_tapGestureRegognizer setCancelsTouchesInView:NO];
    [_tapGestureRegognizer setDelegate:self];
    [self addGestureRecognizer:_tapGestureRegognizer];
}

- (void)hideKeyboard:(id)sender
{
	if ([self.delegate respondsToSelector:@selector(hideKeyboardForTextView:)])
	{
		[self.delegate hideKeyboardForTextView:self.activeTextView];
	}
	else
	{
		[self.activeTextView resignFirstResponder];
	}
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    [self setKeyboardShown:YES];
	self.keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	self.scrollEnabled = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self setKeyboardShown:NO];
	self.keyboardRect = CGRectZero;
	self.keyboardAnimationTimeInterval = [self keyboardAnimationDurationForNotification:notification];
	[self restoreContent];
	self.scrollEnabled = NO;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect convertedFrame = [self convertRect:keyboardFrame fromView:self.window];
	self.keyboardAnimationTimeInterval = [self keyboardAnimationDurationForNotification:notification];
    [self moveContent:convertedFrame];
}

- (void)restoreContent
{
	[UIView animateWithDuration:self.keyboardAnimationTimeInterval animations:^{
		UIEdgeInsets contentInsets = UIEdgeInsetsZero;
		self.contentInset = contentInsets;
		self.scrollIndicatorInsets = contentInsets;
		self.contentSize = self.originalContentSize;
		self.contentOffset = CGPointZero;
	}];
}

- (void)moveContent:(CGRect)keyboardFrame
{
	// Save the original content size
	if (!self.contentSizeSaved)
	{
		self.originalContentSize = self.contentSize;
		self.contentSizeSaved = YES;
	}
	
    CGRect intersectedKeyboardFrame = CGRectIntersection(self.frame, keyboardFrame);
	CGRect aRect = self.frame;
	aRect.size.height -= intersectedKeyboardFrame.size.height;
	
	
	// The focused view will be centered in the available space between the top of the scrollview
	// and the rect occupied by the keyboard
	CGRect availableSpaceRect = self.frame;
	availableSpaceRect.size.height -= intersectedKeyboardFrame.size.height + 66;
    
	// Compute the textView bounds in the local coordinates
	CGRect activeTextViewFrame = [self convertRect:self.activeTextView.frame fromView:self.activeTextView];
    
	// Update the scrollview's content size
	self.contentSize = CGSizeMake(self.originalContentSize.width, self.originalContentSize.height + keyboardFrame.size.height + contentSizeBottomOffset);
    
	// Move the scrollview
	CGFloat distanceFromScrollDestination = activeTextViewFrame.origin.y - (availableSpaceRect.origin.y + availableSpaceRect.size.height / 2) + 30;
	if (distanceFromScrollDestination < 0)
	{
		distanceFromScrollDestination = 0;
	}
    
	CGRect newVisibleRect = availableSpaceRect;
	newVisibleRect.origin.y = self.activeTextView.frameY;
	[UIView animateWithDuration:self.keyboardAnimationTimeInterval animations:^{
		self.contentOffset = CGPointMake(0, distanceFromScrollDestination);
	}];
	
}

- (void)textViewActivated:(UIView *)textView
{
	BOOL shouldAutoScroll = YES;
	if ([self.delegate respondsToSelector:@selector(shouldAutoScrollForTextView:)])
	{
		shouldAutoScroll = [self.delegate shouldAutoScrollForTextView:textView];
	}
    
	if (shouldAutoScroll)
	{
		self.activeTextView = textView;
		if (self.isKeyboardShown)
		{
			// If the keyboard is not shown, the content handling will be performed when the keyboard
			// notification will be received
			[self moveContent:self.keyboardRect];
		}
	}
}

- (void)textViewDeactivated:(UIView *)textView
{
	if (textView == self.activeTextView)
	{
		self.activeTextView = nil;
		if (!self.isKeyboardShown)
		{
			[self restoreContent];
		}
	}
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == [self tapGestureRegognizer])
	{
        if ([[touch view] isKindOfClass:[UIControl class]])
		{
            return NO;
        }
    }
    
    return YES;
}

- (NSTimeInterval)keyboardAnimationDurationForNotification:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue:&duration];
    return duration;
}

@end
