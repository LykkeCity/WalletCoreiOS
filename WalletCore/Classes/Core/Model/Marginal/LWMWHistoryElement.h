//
//  LWMWHistoryElement.h
//  LykkeWallet
//
//  Created by Andrey Snetkov on 17/01/2017.
//  Copyright © 2017 Lykkex. All rights reserved.
//

#import "LWMWHistoryPosition.h"

typedef enum {OPEN, CLOSE, DEPOSIT, WITHDRAW} HISTORY_ELEMENT_TYPE;

@interface LWMWHistoryElement : LWMWHistoryPosition

@property HISTORY_ELEMENT_TYPE type;

@property (strong, nonatomic) NSDate *dateTime;
@property (readonly) NSString *positionString;
@property (readonly) NSString *closeReasonString;

@end
