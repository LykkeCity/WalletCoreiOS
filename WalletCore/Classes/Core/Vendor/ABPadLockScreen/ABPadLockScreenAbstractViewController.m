// ABPadLockScreenAbstractViewController.m
//
// Copyright (c) 2015 Aron Bury - http://www.aronbury.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ABPadLockScreenAbstractViewController.h"
#import "ABPadLockScreenView.h"
#import "ABPinSelectionView.h"
#import <AudioToolbox/AudioToolbox.h>

#define lockScreenView ((ABPadLockScreenView *) [self view])
#define kABPadLockScreenDefaultSimplePinLength 4


@interface ABPadLockScreenAbstractViewController () {
    
}

#pragma mark - Private

- (void)setUpButtonMapping;
- (void)buttonSelected:(UIButton *)sender;
- (void)deleteButtonSelected:(UIButton *)sender;
- (void)okButtonSelected:(UIButton *)sender;

@end


@implementation ABPadLockScreenAbstractViewController


#pragma mark - Root

- (instancetype)init {
    self = [super init];
    if (self) {
        _tapSoundEnabled = NO;
        _errorVibrateEnabled = NO;
        _currentPin = @"";
        _complexPin = NO;
        _simplePinLength = kABPadLockScreenDefaultSimplePinLength;
    }
    return self;
}

- (instancetype)initWithSimplePinUsingLength:(NSUInteger)length {
    self = [self init];
    if (self) {
        NSAssert(length > 0, @"Invalid simple PIN length (must be above zero).");
        _simplePinLength = length;
    }
    return self;
}

- (instancetype)initWithComplexPin {
    self = [self init];
    if (self) {
        _complexPin = YES;
    }
    return self;
}


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect bounds = self.view.bounds;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if (bounds.size.width > bounds.size.height) {
            CGFloat height = bounds.size.width;
            CGFloat width = bounds.size.height;
            bounds.size.height = height;
            bounds.size.width = width;
        }
    }
    
    self.view = [[ABPadLockScreenView alloc] initWithFrame:bounds complexPin:self.isComplexPin];
    lockScreenView.simplePinLength = self.simplePinLength;
    
    [self setUpButtonMapping];
    [lockScreenView.deleteButton addTarget:self action:@selector(deleteButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
	[lockScreenView.okButton addTarget:self action:@selector(okButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
}

-(UIInterfaceOrientationMask) supportedInterfaceOrientations {
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

-(BOOL) shouldAutorotate
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
        return YES;
    return NO;
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	if(lockScreenView.backgroundView != nil)
	{
		//Background view is shown - need light content status bar.
		return UIStatusBarStyleLightContent;
	}
	
	//Check background color if light or dark.
	UIColor* color = lockScreenView.backgroundColor;
	
	if(color == nil)
	{
		color = lockScreenView.backgroundColor = [UIColor blackColor];
	}
	
	const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
	
	//Determine brightness
    CGFloat colorBrightness = (CGColorGetNumberOfComponents(color.CGColor) == 2 ?
							   //Black and white color
							   componentColors[0] :
							   //RGB color
							   ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000);
    
	if (colorBrightness < 0.5)
    {
        return UIStatusBarStyleLightContent;
    }
    else
    {
        return UIStatusBarStyleDefault;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}


#pragma mark - Localization

- (void)setLockScreenTitle:(NSString *)title
{
    self.title = title;
    lockScreenView.enterPasscodeLabel.text = title;
}

- (void)setSubtitleText:(NSString *)text
{
    lockScreenView.detailLabel.text = text;
}

- (void)setCancelButtonText:(NSString *)text
{
    [lockScreenView.cancelButton setTitle:text forState:UIControlStateNormal];
    [lockScreenView.cancelButton sizeToFit];
}

- (void)setDeleteButtonText:(NSString *)text
{
    [lockScreenView.deleteButton setTitle:text forState:UIControlStateNormal];
    [lockScreenView.deleteButton sizeToFit];
}

- (void)setEnterPasscodeLabelText:(NSString *)text
{
    lockScreenView.enterPasscodeLabel.text = text;
}

- (void)setBackgroundView:(UIView *)backgroundView
{
	[lockScreenView setBackgroundView:backgroundView];
	
	if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
	{
		[self setNeedsStatusBarAppearanceUpdate];
	}
}


#pragma mark - Private

- (void)setUpButtonMapping
{
    for (UIButton *button in [lockScreenView buttonArray])
    {
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)cancelButtonDisabled:(BOOL)disabled
{
    lockScreenView.cancelButtonDisabled = disabled;
}

- (void)processPin
{
    //Subclass to provide concrete implementation
}


#pragma mark - Buttons Methods

- (void)newPinSelected:(NSInteger)pinNumber
{
    if (!self.isComplexPin && [self.currentPin length] >= self.simplePinLength)
    {
        return;
    }
    
    self.currentPin = [NSString stringWithFormat:@"%@%ld", self.currentPin, (long)pinNumber];
    
	if(self.isComplexPin)
	{
		[lockScreenView updatePinTextfieldWithLength:self.currentPin.length];
	}
	else
	{
		NSUInteger curSelected = [self.currentPin length] - 1;
		[lockScreenView.digitsArray[curSelected]  setSelected:YES animated:YES completion:nil];
    }
		
    if ([self.currentPin length] == 1)
    {
        [lockScreenView showDeleteButtonAnimated:YES completion:nil];
		
		if(self.complexPin)
		{
			[lockScreenView showOKButton:YES animated:YES completion:nil];
		}
    }
    else if (!self.isComplexPin && [self.currentPin length] == self.simplePinLength)
    {
        [lockScreenView.digitsArray.lastObject setSelected:YES animated:YES completion:nil];
        [self processPin];
    }
}

- (void)deleteFromPin
{
    if ([self.currentPin length] == 0)
    {
        return;
    }
    
    self.currentPin = [self.currentPin substringWithRange:NSMakeRange(0, [self.currentPin length] - 1)];
    
	if(self.isComplexPin)
	{
		[lockScreenView updatePinTextfieldWithLength:self.currentPin.length];
	}
	else
	{
		NSUInteger pinToDeselect = [self.currentPin length];
		[lockScreenView.digitsArray[pinToDeselect] setSelected:NO animated:YES completion:nil];
	}
    
    if ([self.currentPin length] == 0)
    {
        [lockScreenView showCancelButtonAnimated:YES completion:nil];
		[lockScreenView showOKButton:NO animated:YES completion:nil];
    }
}

- (void)clearPin {
    self.currentPin = @"1";
    [self deleteFromPin];
}

- (void)buttonSelected:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    if (self.tapSoundEnabled)
    {
        AudioServicesPlaySystemSound(1105);
    }
    [self newPinSelected:tag];
}

- (void)deleteButtonSelected:(UIButton *)sender
{
    [self deleteFromPin];
}

- (void)okButtonSelected:(UIButton *)sender
{
	[self processPin];
}

@end
