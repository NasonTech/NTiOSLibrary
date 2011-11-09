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

#import "NTCGGeometry.h"

/** Use the NTUIToolTipView class to display a descriptive message about another visual element.
 */
@interface NTUIToolTipView : UIView

typedef NSUInteger NTUIToolTipViewOrientation;
typedef NSUInteger NTUIToolTipViewArrowPosition;

///-----------------------------------------------------------------------------
/// @name Creating Tool Tip Views
///-----------------------------------------------------------------------------

/** Convenience method for initializing a tool tip view.
 
 @param message Descriptive text that provides more details than the title.
 */
- (id)initWithMessage:(NSString *)message;

/** Convenience method for initializing a tool tip view.

 @param title The string that appears in the receiver's title bar.
 @param message Descriptive text that provides more details than the title.
 */
- (id)initWithTitle:(NSString *)title message:(NSString *)message;

/** Convenience method for initializing a tool tip view.
 
 @param title The string that appears in the receiver's title bar.
 @param message Descriptive text that provides more details than the title.
 @param item The element in which to point at.
 */
- (id)initWithTitle:(NSString *)title message:(NSString *)message pointAt:(id)item;

///-----------------------------------------------------------------------------
/// @name Setting Properties
///-----------------------------------------------------------------------------

/** The string that appears in the receiver's title bar. */
@property (nonatomic, retain) NSString *title;
/** Descriptive text that provides more details than the title. */
@property (nonatomic, retain) NSString *message;
/** The frame in which to point at in screen coordinates. */
@property (nonatomic, assign) CGRect pointAt;
/** The receiver's fill color. */
@property (nonatomic, retain) UIColor *fillColor;
/** The receiver's border color. */
@property (nonatomic, retain) UIColor *borderColor;
/** The receiver's text color. */
@property (nonatomic, retain) UIColor *textColor;
/** The spacing between the border and text. */
@property (nonatomic, assign) NTCGOffset padding;
/** The spacing between the tooltip and window. */
@property (nonatomic, assign) NTCGOffset margin;
/** The size of the arrow. */
@property (nonatomic, assign) CGSize arrowSize;
/** The radius used to draw the tooltip. */
@property (nonatomic, assign) NSInteger cornerRadius;
/** The orientation of the tooltip around the view it's pointing at. */
@property (nonatomic, assign) NTUIToolTipViewOrientation orientation;
/** The order that NTUIToolTipViewOrientationAuto uses to auto orient. */
@property (nonatomic, retain) NSArray *orientationOrder;
/** The position of the arrow. */
@property (nonatomic, assign) NTUIToolTipViewArrowPosition arrowPosition;
/** Determines if the receiver will shrink to maintain its visibility on screen. */
@property (nonatomic, assign) BOOL shrinkToFit;
/** The minimum amount the receiver will shrink when adjusting itself to remain on screen. */
@property (nonatomic, assign) CGFloat maximumShrink;

/** Helper method that automatically figures out the frame for various elements

 @param item The element in which to point at
 */
- (void)pointAt:(id)item;

///-----------------------------------------------------------------------------
/// @name Displaying
///-----------------------------------------------------------------------------

/** Displays the receiver. */
- (void)showAnimated:(BOOL)animated;
/** Displays the receiver using animation. */
- (void)show;

///-----------------------------------------------------------------------------
/// @name Dismissing
///-----------------------------------------------------------------------------

/** Dismisses the receiver */
- (void)dismiss;

enum
{
	NTUIToolTipViewOrientationAuto,
	NTUIToolTipViewOrientationTop,
	NTUIToolTipViewOrientationBottom,
	NTUIToolTipViewOrientationLeft,
	NTUIToolTipViewOrientationRight,
	NTUIToolTipViewOrientationNone,
};

enum
{
	NTUIToolTipViewArrowPositionAuto,
	NTUIToolTipViewArrowPositionFixed,
};

- (BOOL)isWordInString:(NSString *)string WiderThanConstraint:(CGSize)constraint withFont:(UIFont *)font;
- (NSInteger)widthOfBiggestWordInString:(NSString *)string withFont:(UIFont *)font;
- (void)drawRoundedRectWithArrow:(CGRect)rect inContext:(CGContextRef)context withRadius:(CGFloat)radius pointingAtFrame:(CGRect)frame;
- (void)animateToSize:(NSString *)id finished:(NSNumber *)finished context:(void *)context;

- (NSArray *)calculateOriginAndArrowPlacementForOrientation:(NTUIToolTipViewOrientation)orientation;
- (CGRect)calculateFrameForOrientation:(NTUIToolTipViewOrientation)orientation;
- (NTUIToolTipViewOrientation)calculateOrientation;

@end