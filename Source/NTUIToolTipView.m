// Copyright (c) 2011, Nason Tech.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
// 
// Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, TH
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.

#import "NTUIToolTipView.h"
#import <QuartzCore/QuartzCore.h>

@implementation NTUIToolTipView
{
	UILabel *titleLabel;
	UILabel *messageLabel;
	CGRect pointAtFrameInWindow;
}

@synthesize title = _title;
@synthesize message = _message;
@synthesize pointAt = _pointAt;
@synthesize fillColor = _fillColor;
@synthesize borderColor = _borderColor;
@synthesize textColor = _textColor;
@synthesize padding = _padding;
@synthesize margin = _margin;
@synthesize arrowSize = _arrowSize; // Height = length, Width = base
@synthesize cornerRadius = _cornerRadius;
@synthesize orientation = _orientation;
@synthesize orientationOrder = _orientationOrder;
@synthesize arrowPosition = _arrowPosition;

- (id)initWithTitle:(NSString *)title message:(NSString *)message
{
	self = [super init];
	if (self)
	{
		self.title = title;
		self.message = message;
		self.backgroundColor = [UIColor clearColor];
		self.fillColor = [UIColor colorWithRed:11/255.0 green:27/255.0 blue:68/255.0 alpha:0.80];
		self.borderColor = [UIColor colorWithRed:223/255.0 green:225/255.0 blue:230/255.0 alpha:1.0];
		self.padding = NTCGOffsetMake(15, 15, 15, 15);
		self.margin = NTCGOffsetMake(10, 10, 10, 10);
		self.arrowSize = CGSizeMake(20, 20);
		self.orientation = NTUIToolTipViewOrientationAuto;
		self.cornerRadius = 8;
		self.orientationOrder = [[NSArray alloc] initWithObjects:[NSNumber numberWithUnsignedInt:NTUIToolTipViewOrientationTop],
																 [NSNumber numberWithUnsignedInt:NTUIToolTipViewOrientationBottom],
																 [NSNumber numberWithUnsignedInt:NTUIToolTipViewOrientationLeft],
																 [NSNumber numberWithUnsignedInt:NTUIToolTipViewOrientationRight], nil];

		self.layer.shadowColor = [[UIColor blackColor] CGColor];
		self.layer.shadowOpacity = 0.7;
		self.layer.shadowOffset = CGSizeMake(0, 5);
		self.layer.shadowRadius = 3.0;
		self.clipsToBounds = NO;

		titleLabel = [[UILabel alloc] init];
		[titleLabel setText:self.title];
		[titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setTextColor:[UIColor whiteColor]];
		[titleLabel setLineBreakMode:UILineBreakModeTailTruncation];
		[self addSubview:titleLabel];

		messageLabel = [[UILabel alloc] init];
		[messageLabel setText:self.message];
		[messageLabel setFont:[UIFont systemFontOfSize:17]];
		[messageLabel setBackgroundColor:[UIColor clearColor]];
		[messageLabel setTextColor:[UIColor whiteColor]];
		[messageLabel setLineBreakMode:UILineBreakModeWordWrap];
		[messageLabel setTextAlignment:UITextAlignmentCenter];
		[messageLabel setNumberOfLines:10];
		[self addSubview:messageLabel];

		UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
		for (UIWindow *window in [[UIApplication sharedApplication] windows])
			if (![NSStringFromClass([window class]) isEqualToString:@"_UIAlertNormalizingOverlayWindow"])
				mainWindow = window;

		[self setHidden:YES];
		[mainWindow addSubview:self];
	}
	return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message pointAt:(id)item
{
	self = [self initWithTitle:title message:message];

	if ([item isKindOfClass:[UIView class]])
		self.pointAt = item;
	else
		self.pointAt = [item valueForKey:@"view"];

	return self;
}

#define SPACING 10

- (void)showAnimated:(BOOL)animated
{
	[self setHidden:NO];

	if (animated)
	{
		[self setAlpha:0.0];
		[UIView beginAnimations:@"ToolTipAppear" context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animateToSize:finished:context:)];
		self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.25, 1.25);
		[self setAlpha:1.0];
		[UIView commitAnimations];
	}
}

- (void)show
{
	[self showAnimated:YES];
}

- (void)animateToSize:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[UIView beginAnimations:animationID context:context];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (void)dismiss
{
	[self removeFromSuperview];
}

- (void)setPointAt:(UIView *)pointAt
{
	[_pointAt release], _pointAt = nil;
	_pointAt = [pointAt retain];

	self.frame = [self calculateFrameForOrientation:[self calculateOrientation]];
	pointAtFrameInWindow = [self.pointAt.superview convertRect:self.pointAt.frame toView:nil];
}

- (void)didMoveToSuperview
{
	pointAtFrameInWindow = [self.pointAt.superview convertRect:self.pointAt.frame toView:nil];
}

// Frame calculations
- (NSArray *)calculateOriginAndArrowPlacementForOrientation:(NTUIToolTipViewOrientation)orientation
{
	NSArray *array = [[[NSArray alloc] init] autorelease];
	return array;
}

- (BOOL)isWordInString:(NSString *)string WiderThanConstraint:(CGSize)constraint withFont:(UIFont *)font
{
	NSArray *words = [string componentsSeparatedByString:@" "];
	for (NSString *word in words)
	{
		CGSize wordSize = [word sizeWithFont:font];
		if (wordSize.width > constraint.width)
			return YES;
	}

	return NO;
}

- (NSInteger)widthOfBiggestWordInString:(NSString *)string withFont:(UIFont *)font
{
	NSArray *words = [string componentsSeparatedByString:@" "];
	NSInteger width = 0;
	for (NSString *word in words)
	{
		CGSize wordSize = [word sizeWithFont:font];
		if (wordSize.width > width)
			width = wordSize.width;
	}
	
	return width;
}

- (CGRect)calculateFrameForOrientation:(NTUIToolTipViewOrientation)orientation
{
	CGRect frame = CGRectMake(0, 0, 0, 0);

	CGRect pointAtFrameInWindowA = [self.pointAt.superview convertRect:self.pointAt.frame toView:nil];
	
	if (orientation == NTUIToolTipViewOrientationTop)
	{
		CGFloat frameMaxWidth = self.superview.frame.size.width - NTCGOffsetGetWidth(self.margin);
		CGFloat frameMaxHeight = CGRectGetMinY(self.pointAt.frame) - NTCGOffsetGetHeight(self.margin);

		CGSize contentsMaxSize = CGSizeMake(frameMaxWidth - NTCGOffsetGetWidth(self.padding),
											frameMaxHeight - NTCGOffsetGetHeight(self.padding) - self.arrowSize.height);
		CGSize titleMinSize = [self.title sizeWithFont:titleLabel.font
									 constrainedToSize:contentsMaxSize
										 lineBreakMode:titleLabel.lineBreakMode];
		CGSize messageMinSize = [self.message sizeWithFont:messageLabel.font
										 constrainedToSize:contentsMaxSize
											 lineBreakMode:messageLabel.lineBreakMode];

		NSInteger messageMinWordSize = [self widthOfBiggestWordInString:self.message withFont:messageLabel.font];
		if (messageMinWordSize > messageMinSize.width)
			messageMinSize.width = messageMinWordSize;

		CGFloat frameWidth = fmaxf(titleMinSize.width, messageMinSize.width) + NTCGOffsetGetWidth(self.padding);
		CGFloat frameHeight = fmaxf(titleMinSize.height, messageMinSize.height) + NTCGOffsetGetHeight(self.padding) + self.arrowSize.height;

		CGFloat frameLeft = CGRectGetMidX(pointAtFrameInWindowA) - frameWidth / 2;
		CGFloat frameTop = CGRectGetMinY(pointAtFrameInWindowA) - frameHeight;
		
		frame = CGRectMake(frameLeft, frameTop, frameWidth, frameHeight);
	}
	else if (orientation == NTUIToolTipViewOrientationBottom)
	{
		CGFloat frameMaxWidth = self.superview.frame.size.width - NTCGOffsetGetWidth(self.margin);
		CGFloat frameMaxHeight = CGRectGetMinY(self.pointAt.frame) - NTCGOffsetGetHeight(self.margin);

		CGSize contentsMaxSize = CGSizeMake(frameMaxWidth - NTCGOffsetGetWidth(self.padding),
											frameMaxHeight - NTCGOffsetGetHeight(self.padding) - self.arrowSize.height);
		CGSize titleMinSize = [self.title sizeWithFont:titleLabel.font
									 constrainedToSize:contentsMaxSize
										 lineBreakMode:titleLabel.lineBreakMode];
		CGSize messageMinSize = [self.message sizeWithFont:messageLabel.font
										 constrainedToSize:contentsMaxSize
											 lineBreakMode:messageLabel.lineBreakMode];

		CGFloat frameWidth = fmaxf(titleMinSize.width, messageMinSize.width) + NTCGOffsetGetWidth(self.padding);
		CGFloat frameHeight = fmaxf(titleMinSize.height, messageMinSize.height) + NTCGOffsetGetHeight(self.padding) + self.arrowSize.height;

		CGFloat frameLeft = CGRectGetMidX(pointAtFrameInWindowA) - frameWidth / 2;
		CGFloat frameTop = CGRectGetMaxY(pointAtFrameInWindowA);

		frame = CGRectMake(frameLeft, frameTop, frameWidth, frameHeight);
	}
	else if (orientation == NTUIToolTipViewOrientationLeft)
	{
		CGFloat frameMaxWidth = CGRectGetMinX(self.pointAt.frame) - self.margin.left;
		CGFloat frameMaxHeight = self.superview.frame.size.height - NTCGOffsetGetHeight(self.margin);

		CGSize contentsMaxSize = CGSizeMake(frameMaxWidth - NTCGOffsetGetWidth(self.padding) - self.arrowSize.height,
											frameMaxHeight - NTCGOffsetGetHeight(self.padding));
		CGSize titleMinSize = [self.title sizeWithFont:titleLabel.font
									 constrainedToSize:contentsMaxSize
										 lineBreakMode:titleLabel.lineBreakMode];
		CGSize messageMinSize = [self.message sizeWithFont:messageLabel.font
										 constrainedToSize:contentsMaxSize
											 lineBreakMode:messageLabel.lineBreakMode];

		CGFloat frameWidth = fmaxf(titleMinSize.width, messageMinSize.width) + NTCGOffsetGetWidth(self.padding) + self.arrowSize.height;
		CGFloat frameHeight = fmaxf(titleMinSize.height, messageMinSize.height) + NTCGOffsetGetHeight(self.padding);

		CGFloat frameLeft = CGRectGetMinX(pointAtFrameInWindowA) - frameWidth;
		CGFloat frameTop = CGRectGetMidY(pointAtFrameInWindowA) - frameHeight / 2;
		
		frame = CGRectMake(frameLeft, frameTop, frameWidth, frameHeight);
	}
	else if (orientation == NTUIToolTipViewOrientationRight)
	{
		CGFloat frameMaxWidth = self.superview.frame.size.width - CGRectGetMaxX(self.pointAt.frame) - self.margin.right;
		CGFloat frameMaxHeight = self.superview.frame.size.height - NTCGOffsetGetHeight(self.margin);

		CGSize contentsMaxSize = CGSizeMake(frameMaxWidth - CGRectGetMaxX(self.pointAt.frame) - self.margin.right,
											frameMaxHeight - NTCGOffsetGetHeight(self.padding));
		CGSize titleMinSize = [self.title sizeWithFont:titleLabel.font
									 constrainedToSize:contentsMaxSize
										 lineBreakMode:titleLabel.lineBreakMode];
		CGSize messageMinSize = [self.message sizeWithFont:messageLabel.font
										 constrainedToSize:contentsMaxSize
											 lineBreakMode:messageLabel.lineBreakMode];

		CGFloat frameWidth = fmaxf(titleMinSize.width, messageMinSize.width) + NTCGOffsetGetWidth(self.padding) + self.arrowSize.height;
		CGFloat frameHeight = fmaxf(titleMinSize.height, messageMinSize.height) + NTCGOffsetGetHeight(self.padding);

		CGFloat frameLeft = CGRectGetMaxX(pointAtFrameInWindowA);
		CGFloat frameTop = CGRectGetMidY(pointAtFrameInWindowA) - frameHeight / 2;
		
		frame = CGRectMake(frameLeft, frameTop, frameWidth, frameHeight);
	}

	return frame;
}

- (NTUIToolTipViewOrientation)calculateOrientation
{
	if (self.orientation != NTUIToolTipViewOrientationAuto)
		return self.orientation;

	CGRect topPlacementFrame = [self calculateFrameForOrientation:NTUIToolTipViewOrientationTop];
	CGRect bottomPlacementFrame = [self calculateFrameForOrientation:NTUIToolTipViewOrientationBottom];
	CGRect leftPlacementFrame = [self calculateFrameForOrientation:NTUIToolTipViewOrientationLeft];
	CGRect rightPlacementFrame = [self calculateFrameForOrientation:NTUIToolTipViewOrientationRight];

	CGFloat topOffset = CGRectGetMidX(topPlacementFrame) - CGRectGetMidX(self.pointAt.frame);
	CGFloat bottomOffset = CGRectGetMidX(bottomPlacementFrame) - CGRectGetMidX(self.pointAt.frame);
	CGFloat leftOffset = CGRectGetMidY(leftPlacementFrame) - CGRectGetMidY(self.pointAt.frame);
	CGFloat rightOffset = CGRectGetMidY(rightPlacementFrame) - CGRectGetMidY(self.pointAt.frame);

	NSMutableDictionary *offsetsAbsolute = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithFloat:fabsf(topOffset)],
																												[NSNumber numberWithFloat:fabsf(bottomOffset)],
																												[NSNumber numberWithFloat:fabsf(leftOffset)],
																												[NSNumber numberWithFloat:fabsf(rightOffset)], nil]
																			  forKeys:[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:NTUIToolTipViewOrientationTop],
																												[NSNumber numberWithUnsignedInteger:NTUIToolTipViewOrientationBottom],
																												[NSNumber numberWithUnsignedInteger:NTUIToolTipViewOrientationLeft],
																												[NSNumber numberWithUnsignedInteger:NTUIToolTipViewOrientationRight], nil]];
	NSArray *orientationsOrderedByOffset = [offsetsAbsolute keysSortedByValueUsingSelector:@selector(compare:)];

	CGRect superFrameMinusMargin = CGRectMake(self.superview.frame.origin.x + self.margin.left,
											  self.superview.frame.origin.y + self.margin.top + UIApplication.sharedApplication.statusBarFrame.size.height,
											  self.superview.frame.size.width - NTCGOffsetGetWidth(self.margin),
											  self.superview.frame.size.height - NTCGOffsetGetHeight(self.margin) - UIApplication.sharedApplication.statusBarFrame.size.height);
	for (NSNumber *orientationNumber in orientationsOrderedByOffset)
	{
		NTUIToolTipViewOrientation orientation = [orientationNumber unsignedIntValue];
		if (orientation == NTUIToolTipViewOrientationTop)
		{
			CGRect clippedRect = CGRectIntersection(superFrameMinusMargin, topPlacementFrame);
			if (CGRectEqualToRect(clippedRect, topPlacementFrame))
				return NTUIToolTipViewOrientationTop;
		}
		else if (orientation == NTUIToolTipViewOrientationBottom)
		{
			CGRect clippedRect = CGRectIntersection(superFrameMinusMargin, bottomPlacementFrame);
			if (CGRectEqualToRect(clippedRect, bottomPlacementFrame))
				return NTUIToolTipViewOrientationBottom;
		}
		else if (orientation == NTUIToolTipViewOrientationLeft)
		{
			CGRect clippedRect = CGRectIntersection(superFrameMinusMargin, leftPlacementFrame);
			if (CGRectEqualToRect(clippedRect, leftPlacementFrame))
				return NTUIToolTipViewOrientationLeft;
		}
		else if (orientation == NTUIToolTipViewOrientationRight)
		{
			CGRect clippedRect = CGRectIntersection(superFrameMinusMargin, rightPlacementFrame);
			if (CGRectEqualToRect(clippedRect, rightPlacementFrame))
				return NTUIToolTipViewOrientationRight;
		}
	}

	titleLabel.font = [titleLabel.font fontWithSize:titleLabel.font.pointSize - 0.1];
	messageLabel.font = [messageLabel.font fontWithSize:messageLabel.font.pointSize - 0.1];

	return [self calculateOrientation];

	return NTUIToolTipViewOrientationNone;
}

- (void)layoutSubviews
{
	NTUIToolTipViewOrientation orientation = [self calculateOrientation];

	CGSize contentsMaxSize = CGSizeMake(self.bounds.size.width - NTCGOffsetGetWidth(self.padding),
										self.bounds.size.height - NTCGOffsetGetHeight(self.padding));
	if (orientation == NTUIToolTipViewOrientationTop || orientation == NTUIToolTipViewOrientationBottom)
		contentsMaxSize.height -= self.arrowSize.height;
	else if (orientation == NTUIToolTipViewOrientationLeft || orientation == NTUIToolTipViewOrientationRight)
		contentsMaxSize.width -= self.arrowSize.height;

	if ([self.title isEqualToString:@""] || self.title != nil)
	{
		CGSize titleMinSize = [self.title sizeWithFont:titleLabel.font
									 constrainedToSize:contentsMaxSize
										 lineBreakMode:titleLabel.lineBreakMode];
		CGRect titleFrame = CGRectMake(self.padding.left,
									   self.padding.top,
									   titleMinSize.width,
									   titleMinSize.height);

		if (orientation == NTUIToolTipViewOrientationBottom)
			titleFrame.origin.y += self.arrowSize.height;
		else if (orientation == NTUIToolTipViewOrientationRight)
			titleFrame.origin.x += self.arrowSize.height;

		titleLabel.frame = titleFrame;
	}
	else
	{
		titleLabel.frame = CGRectMake(0, 0, 0, 0);
		titleLabel.hidden = YES;
	}

	if ([self.message isEqualToString:@""] || self.message != nil)
	{
		CGSize messageMinSize = [self.message sizeWithFont:messageLabel.font
										 constrainedToSize:contentsMaxSize
											 lineBreakMode:messageLabel.lineBreakMode];
		CGRect messageFrame = CGRectMake(self.padding.left,
									     (messageLabel.frame.size.height > 0) ? ( CGRectGetMaxY(messageLabel.frame) + SPACING ) : ( self.padding.top ),
									     messageMinSize.width,
									     messageMinSize.height);

		if (orientation == NTUIToolTipViewOrientationBottom)
			messageFrame.origin.y += self.arrowSize.height;
		else if (orientation == NTUIToolTipViewOrientationRight)
			messageFrame.origin.x += self.arrowSize.height;

		messageLabel.frame = messageFrame;
	}
	else
	{
		messageLabel.frame = CGRectMake(0, 0, 0, 0);
		messageLabel.hidden = YES;
	}
}

- (void)drawRect:(CGRect)rect
{
	// Get drawing context
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Setup context
	CGContextClearRect(context, rect);
	CGContextSetAllowsAntialiasing(context, true);
	CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
	CGContextSetFillColorWithColor(context, self.fillColor.CGColor);

	// Create new container rect
	CGRect containerRect = CGRectInset(rect, 2, 2);
	NTUIToolTipViewOrientation orientation = [self calculateOrientation];
	if (orientation == NTUIToolTipViewOrientationTop || orientation == NTUIToolTipViewOrientationBottom)
		containerRect.size.height -= self.arrowSize.height;
	else if (orientation == NTUIToolTipViewOrientationLeft || orientation == NTUIToolTipViewOrientationRight)
		containerRect.size.width -= self.arrowSize.height;

	if (orientation == NTUIToolTipViewOrientationBottom)
		CGContextTranslateCTM(context, 0, self.arrowSize.height);
	else if (orientation == NTUIToolTipViewOrientationRight)
		CGContextTranslateCTM(context, self.arrowSize.height, 0);

	// Draw shape
	[self drawRoundedRectWithArrow:containerRect inContext:context withRadius:8 pointingAtFrame:self.pointAt.frame];
	CGContextSetLineWidth(context, 2.0);
	CGContextDrawPath(context, kCGPathFillStroke);

	// Draw center radial burst
	CGFloat colorsBurst[] = {
		1.0, 1.0, 1.0, 0.25,
		1.0, 1.0, 1.0, 0.00,
	};

	[self drawRoundedRectWithArrow:containerRect inContext:context withRadius:8 pointingAtFrame:self.pointAt.frame];
	CGContextClip(context);

	CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradientBurst = CGGradientCreateWithColorComponents(rgbColorspace, colorsBurst, NULL, 2);
	CGColorSpaceRelease(rgbColorspace), rgbColorspace = nil;

	CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
	CGContextDrawRadialGradient(context, gradientBurst, center, 0, center, rect.size.width, 0);
	CGGradientRelease(gradientBurst), gradientBurst = nil;

	// Top Highlight
	CGRect rectHighlight = CGRectMake(-50, -45, rect.size.width + 50 * 2, 75);
	CGContextAddEllipseInRect(context, rectHighlight);
	CGContextSetLineWidth(context, 0);
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextSetAlpha(context, 0.25);
	CGContextDrawPath(context, kCGPathFill);
}

- (void)drawRoundedRectWithArrow:(CGRect)rect inContext:(CGContextRef)context withRadius:(CGFloat)radius pointingAtFrame:(CGRect)frame
{
	CGContextBeginPath(context);

	CGRect roundedRect = CGRectInset(rect, self.cornerRadius, self.cornerRadius);

	CGFloat minx = CGRectGetMinX(rect);
	CGFloat midx = CGRectGetMidX(rect);
	CGFloat maxx = CGRectGetMaxX(rect);

	CGFloat miny = CGRectGetMinY(rect);
	CGFloat midy = CGRectGetMidY(rect);
	CGFloat maxy = CGRectGetMaxY(rect);

	NSUInteger orientationCalculated;
	if (self.orientation != NTUIToolTipViewOrientationAuto)
		orientationCalculated = self.orientation;
	else
		orientationCalculated = [self calculateOrientation];

	if (orientationCalculated == NTUIToolTipViewOrientationBottom)
	{
		CGPoint arrowPoint = CGPointMake(midx, miny);

		CGContextMoveToPoint(context, arrowPoint.x - (self.arrowSize.width / 2), arrowPoint.y);
		CGContextAddLineToPoint(context, arrowPoint.x, arrowPoint.y - self.arrowSize.height);
		CGContextAddLineToPoint(context, arrowPoint.x + (self.arrowSize.height / 2), arrowPoint.y);
	}
	else
		CGContextMoveToPoint(context, midx, miny);

	CGContextAddArc(context, CGRectGetMaxX(roundedRect), CGRectGetMinY(roundedRect), self.cornerRadius, -M_PI_2, 0, NO);

	if (orientationCalculated == NTUIToolTipViewOrientationLeft)
	{
		CGPoint arrowPoint = CGPointMake(maxx, midy);

		CGContextAddLineToPoint(context, arrowPoint.x, arrowPoint.y - (self.arrowSize.width / 2));
		CGContextAddLineToPoint(context, arrowPoint.x + self.arrowSize.height, arrowPoint.y);
		CGContextAddLineToPoint(context, arrowPoint.x, arrowPoint.y + (self.arrowSize.height / 2));
	}

	CGContextAddArc(context, CGRectGetMaxX(roundedRect), CGRectGetMaxY(roundedRect), self.cornerRadius, 0, M_PI_2, NO);

	if (orientationCalculated == NTUIToolTipViewOrientationTop)
	{
		CGPoint arrowPoint = CGPointMake(midx, maxy);

		CGContextAddLineToPoint(context, arrowPoint.x + (self.arrowSize.width / 2), arrowPoint.y);
		CGContextAddLineToPoint(context, arrowPoint.x, arrowPoint.y + self.arrowSize.height);
		CGContextAddLineToPoint(context, arrowPoint.x - (self.arrowSize.height / 2), arrowPoint.y);
	}

	CGContextAddArc(context, CGRectGetMinX(roundedRect), CGRectGetMaxY(roundedRect), self.cornerRadius, M_PI_2, M_PI, NO);

	if (orientationCalculated == NTUIToolTipViewOrientationRight)
	{
		CGPoint arrowPoint = CGPointMake(minx, midy);

		CGContextAddLineToPoint(context, arrowPoint.x, arrowPoint.y + (self.arrowSize.width / 2));
		CGContextAddLineToPoint(context, arrowPoint.x - self.arrowSize.height, arrowPoint.y);
		CGContextAddLineToPoint(context, arrowPoint.x, arrowPoint.y - (self.arrowSize.height / 2));
	}

	CGContextAddArc(context, CGRectGetMinX(roundedRect), CGRectGetMinY(roundedRect), self.cornerRadius, M_PI, -M_PI_2, NO);

	CGContextClosePath(context);
}

@end