//
//  LWNewsElementModel.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 30/08/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWNewsElementModel.h"
#import "NSString+Date.h"

@implementation LWNewsElementModel

-(id) initWithDictionary:(NSDictionary *) dict
{
    self=[super init];
    
    _title=dict[@"Title"];
    _author=dict[@"Author"];
    
    
    _text=dict[@"Text"];
    if(dict[@"Url"])
        _detailsURL=[NSURL URLWithString:dict[@"Url"]];
    if(dict[@"ImgUrl"])
        _imageURL=[NSURL URLWithString:dict[@"ImgUrl"]];
    
    _date=[dict[@"DateTime"] toDate];
    
    
    return self;
}

@end
