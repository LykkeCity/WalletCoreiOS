// ABPadLockScreenSetupViewController.m

#import "ABPadLockScreenSetupViewController.h"
#import "ABPadLockScreenView.h"
#import "ABPinSelectionView.h"
#import <AudioToolbox/AudioToolbox.h>

#define lockScreenView ((ABPadLockScreenView *) [self view])


@interface ABPadLockScreenSetupViewController () {
    
}

@property (nonatomic, strong) NSString *enteredPin;


#pragma mark - Private

- (void)startPinConfirmation;
- (void)validateConfirmedPin;

@end


@implementation ABPadLockScreenSetupViewController

#pragma mark - Root

- (instancetype)initWithDelegate:(id<ABPadLockScreenSetupViewControllerDelegate>)delegate {
    return [self initWithDelegate:delegate complexPin:NO];
}

- (instancetype)initWithDelegate:(id<ABPadLockScreenSetupViewControllerDelegate>)delegate complexPin:(BOOL)complexPin
{
    self = (complexPin) ? [super initWithComplexPin] : [super init];
    if (self)
    {
        _setupScreenDelegate = delegate;
        _enteredPin = nil;
        [self setDefaultTexts];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<ABPadLockScreenSetupViewControllerDelegate>)delegate complexPin:(BOOL)complexPin subtitleLabelText:(NSString *)subtitleLabelText
{
    self = [self initWithDelegate:delegate complexPin:complexPin];
    if (self)
    {
        _subtitleLabelText = subtitleLabelText;
        dispatch_async(dispatch_get_main_queue(), ^{
            [lockScreenView updateDetailLabelWithString:_subtitleLabelText animated:NO completion:nil];
        });
    }
    return self;
}

- (void)setDefaultTexts
{
    _pinNotMatchedText = NSLocalizedString(@"ABPadLockScreen.pin.matchError", @"");
    _pinConfirmationText = NSLocalizedString(@"ABPadLockScreen.pin.setup.confirm", @"");
}

#pragma mark -
#pragma mark - View Controller Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [lockScreenView.cancelButton addTarget:self action:@selector(cancelButtonSelected:) forControlEvents:UIControlEventTouchUpInside];    
}

#pragma mark -
#pragma mark - Pin Processing
- (void)processPin
{
    if (!self.enteredPin)
    {
        [self startPinConfirmation];
    }
    else
    {
        [self validateConfirmedPin];
    }
}

- (void)startPinConfirmation
{
    self.enteredPin = self.currentPin;
    self.currentPin = @"";
    [lockScreenView updateDetailLabelWithString:self.pinConfirmationText animated:YES completion:nil];
    [lockScreenView resetAnimated:YES];
}
         
- (void)validateConfirmedPin
{
    if ([self.currentPin isEqualToString:self.enteredPin])
    {
        [self.setupScreenDelegate padLockScreenSetupViewController:self didSetPin:self.currentPin];
    }
    else
    {
        [lockScreenView updateDetailLabelWithString:self.pinNotMatchedText animated:YES completion:nil];
		[lockScreenView animateFailureNotification];
        [lockScreenView resetAnimated:YES];
        self.enteredPin = nil;
        self.currentPin = @"";
        
        // vibrate feedback
        if (self.errorVibrateEnabled)
        {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}

- (void)cancelButtonSelected:(UIButton *)sender
{
    if ([self.setupScreenDelegate respondsToSelector:@selector(didCancelInSetupViewController:)])
    {
        [self.setupScreenDelegate didCancelInSetupViewController:self];
    }
}

@end