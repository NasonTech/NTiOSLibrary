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

#import "RootViewController.h"
#import <NTUIToolTipView.h>
#import "SettingsViewController.h"

@implementation RootViewController
{
	NTUIToolTipView *toolTip;
	UIBarButtonItem *settingsButton;
}

#pragma mark - View lifecycle

- (void)dealloc
{
	[settingsButton release];
	[toolTip release];
	[super dealloc];
}

- (void)viewDidLoad
{
	[self.navigationItem setTitle:@"NTUIToolTipViewDemo"];

	settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(doSettings:)];
	[self.navigationItem setRightBarButtonItem:settingsButton];
}

- (void)viewDidAppear:(BOOL)animated
{
	toolTip = [[NTUIToolTipView alloc] initWithMessage:@"Tap anywhere!"];
	CGPoint center = [self.view convertPoint:self.view.center toView:nil];
	[toolTip setPointAt:CGRectMake(center.x, center.y, 1, 1)];
	[toolTip show];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[toolTip dismiss];
	[toolTip release], toolTip = nil;

	toolTip = [[NTUIToolTipView alloc] initWithMessage:@"Tap anywhere!"];
	CGPoint touched = [self.view convertPoint:[[touches anyObject] locationInView:self.view] toView:nil];
	[toolTip setPointAt:CGRectMake(touched.x, touched.y, 1, 1)];
	[toolTip show];
}

- (void)doSettings:(UIBarButtonItem *)button
{
	[toolTip dismiss];
	[toolTip release], toolTip = nil;

	SettingsViewController *settingsViewController = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController_iPhone" bundle:nil];
	[self.navigationController pushViewController:settingsViewController animated:YES];
	[settingsViewController release];
}

@end