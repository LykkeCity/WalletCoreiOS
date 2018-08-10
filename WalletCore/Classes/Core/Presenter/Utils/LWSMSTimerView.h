//
//  LWSMSTimerView.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWSMSTimerView : UIView

-(BOOL) isTimerRunnig;

-(void) viewWillAppear;
-(void) startTimer;

@property id delegate;

@end

@protocol LWSMSTimerViewDelegate

-(void) smsTimerViewPressedResend:(LWSMSTimerView *) view;
-(void) smsTimerViewPressedRequestVoiceCall:(LWSMSTimerView *) view;

@end
