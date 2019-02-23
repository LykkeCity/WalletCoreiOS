// ABPadLockScreenSetupView.h

@import UIKit;

@class ABPinSelectionView;


@interface ABPadLockScreenView : UIView {
    
}

@property (nonatomic, strong) UIFont *enterPasscodeLabelFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *detailLabelFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *deleteCancelLabelFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *labelColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *viewColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIView* backgroundView;

@property (nonatomic, assign) NSUInteger simplePinLength;
@property (nonatomic, assign) BOOL cancelButtonDisabled;

@property (nonatomic, strong, readonly) UILabel *enterPasscodeLabel;
@property (nonatomic, strong, readonly) UILabel *detailLabel;

@property (nonatomic, strong, readonly) UIButton *buttonOne;
@property (nonatomic, strong, readonly) UIButton *buttonTwo;
@property (nonatomic, strong, readonly) UIButton *buttonThree;

@property (nonatomic, strong, readonly) UIButton *buttonFour;
@property (nonatomic, strong, readonly) UIButton *buttonFive;
@property (nonatomic, strong, readonly) UIButton *buttonSix;

@property (nonatomic, strong, readonly) UIButton *buttonSeven;
@property (nonatomic, strong, readonly) UIButton *buttonEight;
@property (nonatomic, strong, readonly) UIButton *buttonNine;

@property (nonatomic, strong, readonly) UIButton *buttonZero;

@property (nonatomic, strong, readonly) UIButton *cancelButton;
@property (nonatomic, strong, readonly) UIButton *deleteButton;

@property (nonatomic, strong, readonly) UIButton *okButton;

/*
 Lazy loaded array that returns all the buttons ordered from 0-9
 */
- (NSArray *)buttonArray;

/*
 The following are used to decide how to display the padlock view - complex (text field) or simple (digits)
 */
@property (nonatomic, assign, readonly, getter = isComplexPin) BOOL complexPin;
@property (nonatomic, strong, readonly) NSArray *digitsArray;
@property (nonatomic, strong, readonly) UITextField *digitsTextField;

- (void)showCancelButtonAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)showDeleteButtonAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)showOKButton:(BOOL)show animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

- (void)updateDetailLabelWithString:(NSString *)string animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

- (void)lockViewAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

- (void)animateFailureNotification;
- (void)resetAnimated:(BOOL)animated;

- (void)updatePinTextfieldWithLength:(NSUInteger)length;

- (id)initWithFrame:(CGRect)frame complexPin:(BOOL)complexPin;

@end
