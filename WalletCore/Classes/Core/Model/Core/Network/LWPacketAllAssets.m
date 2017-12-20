//
//  LWPacketAllAssets.m
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/06/16.
//  Copyright © 2016 Lykkex. All rights reserved.
//

#import "LWPacketAllAssets.h"
#import "LWAssetModel.h"
#import "LWCache.h"

@implementation LWPacketAllAssets

#pragma mark - LWPacket

- (void)parseResponse:(id)response error:(NSError *)error {
  [super parseResponse:response error:error];
  
  if (self.isRejected || !response) {
    return;
  }
  
  NSMutableArray *list = [NSMutableArray new];
  for (NSDictionary *item in result[@"Assets"]) {
    [list addObject:[[LWAssetModel alloc] initWithJSON:item]];
  }
  
  [LWCache instance].allAssets = list;
  if (self.completionBlock != nil) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.completionBlock();
    });
  }
}

- (NSString *)urlRelative {
    return @"Dicts/Assets";
}

- (GDXRESTPacketType)type {
    return GDXRESTPacketTypeGET;
}


@end
