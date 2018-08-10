//
//  LWSMSTimerView.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 20/09/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWSMSTimerView.h"
#import "LWCache.h"

#define SECONDS_TO_WAIT 30

@interface LWSMSTimerView()
{

    UILabel *titleLabel;
    UILabel *timerLabel;
    UIImageView *timerIcon;
    
    UIView *timerContainer;
    
    NSTimer *timer;
    int secondsLeft;
    
    BOOL flagTimerMode;
}

@end

@implementation LWSMSTimerView

-(void) awakeFromNib
{
    [super awakeFromNib];
    [self createViews];
}

-(id) init
{
    self=[super init];
    [self createViews];
    return self;
}

-(id) initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    [self createViews];
    return self;
}

-(void) createViews
{
    timerContainer=[[UIView alloc] init];
    
    titleLabel=[[UILabel alloc] init];
    titleLabel.textColor= UIColor.whiteColor;
    timerLabel=[[UILabel alloc] init];
    timerLabel.text=@"00:00";
    [timerLabel sizeToFit];
    timerLabel.frame=CGRectMake(0, 0, timerLabel.bounds.size.width+5, timerLabel.bounds.size.height);
    timerLabel.text=@"";
    
    timerIcon=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TimerIcon"]];
    timerIcon.frame=CGRectMake(0, 0, 18, 18);
    timerIcon.contentMode=UIViewContentModeCenter;
    
    [self addSubview:titleLabel];
    [timerContainer addSubview:timerLabel];
    [timerContainer addSubview:timerIcon];
    [self addSubview:timerContainer];
    
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapped)];
    [self addGestureRecognizer:gesture];
    
    [LWCache instance].smsDelayDelegate=self;
}

-(void) viewWillAppear
{
    if([LWCache instance].timerSMS)
    {
        flagTimerMode=YES;
        [self adjustTimerTitle];
    }
    else
    {
        flagTimerMode=NO;
    }
    if([LWCache instance].smsRetriesLeft==0)
        titleLabel.text=Localize(@"register.phone.requestCall");
    else
        titleLabel.text=Localize(@"register.phone.haventRecieve");

    [self setNeedsLayout];
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    if(flagTimerMode)
    {
//        [timerLabel sizeToFit];
        timerLabel.center=CGPointMake(timerIcon.bounds.size.width+4+timerLabel.bounds.size.width/2, timerIcon.bounds.size.height/2+1);
        timerContainer.frame=CGRectMake(0, 0, timerLabel.frame.origin.x+timerLabel.bounds.size.width, timerIcon.bounds.size.height);
        timerContainer.center=CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        titleLabel.hidden=YES;
        timerContainer.hidden=NO;
    }
    else
    {
        [titleLabel sizeToFit];
        titleLabel.center=CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        timerContainer.hidden=YES;
        titleLabel.hidden=NO;
    }
    
}

-(void) userTapped
{
    if(flagTimerMode)
        return;
    if([LWCache instance].smsRetriesLeft==0)
    {
        if([self.delegate respondsToSelector:@selector(smsTimerViewPressedRequestVoiceCall:)])
            [self.delegate smsTimerViewPressedRequestVoiceCall:self];
        return;
    }
    if([self.delegate respondsToSelector:@selector(smsTimerViewPressedResend:)])
        [self.delegate smsTimerViewPressedResend:self];
}

-(void) startTimer
{
    [[LWCache instance] startTimerForSMS];
    flagTimerMode=YES;
    [self smsTimerFired];

}

-(void) smsTimerFinished
{
    flagTimerMode=NO;
    if([LWCache instance].smsRetriesLeft==0)
    {
        titleLabel.text=Localize(@"register.phone.requestCall");
    }
    [self setNeedsLayout];
}

-(void) adjustTimerTitle
{
    NSString *seconds=[@([LWCache instance].smsDelaySecondsLeft) stringValue];
    if(seconds.length==1)
        seconds=[@"0" stringByAppendingString:seconds];
    timerLabel.text=[@"00:" stringByAppendingString:seconds];
    [self setNeedsLayout];

}

-(void) smsTimerFired
{
    [self adjustTimerTitle];
}


-(BOOL) isTimerRunnig
{
    return [LWCache instance].timerSMS!=nil;
}

@end
