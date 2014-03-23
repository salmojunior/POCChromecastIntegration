//
//  STChromecastDeviceController.m
//  TestChromeCast
//
//  Created by Salmo Roberto da Silva Junior on 17/02/14.
//  Copyright (c) 2014 Salmo Roberto da Silva Junior. All rights reserved.
//

#import "STGCTextChannel.h"

@implementation STGCTextChannel

- (void)didReceiveTextMessage:(NSString*)message
{
    if ([self.delegate respondsToSelector:@selector(didChannelReceiveTextMessage:)]) {
        [self.delegate didChannelReceiveTextMessage:message];
    }
}

@end