// ABPadLockScreenSetupViewController.h

/**
 This class should be presented to the user to perform the initial pin setup, usually when they open the app for the first time or
 when they wish to reset their pin.
 
 This class will not store the pin for you, you are responsible for taking the pin and saving it SECURELY to later be compared with values from ABPadLockScreenViewController
 */

#import "ABPadLockScreenAbstractViewController.h"

@class ABPadLockScreenSetupViewController;
@protocol ABPadLockScreenSetupViewControllerDelegate;


@interface ABPadLockScreenSetupViewController : ABPadLockScreenAbstractViewController {
    
}

@property (nonatomic, weak, readonly) id<ABPadLockScreenSetupViewControllerDelegate> setupScreenDelegate;
@property (nonatomic, strong, readonly) NSString *subtitleLabelText;
@property (nonatomic, strong) NSString *pinNotMatchedText;
@property (nonatomic, strong) NSString *pinConfirmationText;


- (instancetype)initWithDelegate:(id<ABPadLockScreenSetupViewControllerDelegate>)delegate;
- (instancetype)initWithDelegate:(id<ABPadLockScreenSetupViewControllerDelegate>)delegate complexPin:(BOOL)complexPin;
- (instancetype)initWithDelegate:(id<ABPadLockScreenSetupViewControllerDelegate>)delegate complexPin:(BOOL)complexPin subtitleLabelText:(NSString *)subtitleLabelText;

@end


@protocol ABPadLockScreenSetupViewControllerDelegate <NSObject>
@required
- (void)padLockScreenSetupViewController:(ABPadLockScreenSetupViewController *)controller didSetPin:(NSString *)pin;

@optional
- (void)didCancelInSetupViewController:(ABPadLockScreenAbstractViewController *)controller;

@end