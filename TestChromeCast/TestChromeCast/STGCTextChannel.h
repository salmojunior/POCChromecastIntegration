//
//  STChromecastDeviceController.m
//  TestChromeCast
//
//  Created by Salmo Roberto da Silva Junior on 17/02/14.
//  Copyright (c) 2014 Salmo Roberto da Silva Junior. All rights reserved.
//

#import <GoogleCast/GoogleCast.h>
#import <Foundation/Foundation.h>

@protocol STGCTextChannelDelegate <NSObject>

@optional
- (void)didChannelReceiveTextMessage:(NSString *)message;

@end

@interface STGCTextChannel : GCKCastChannel

@property (nonatomic, strong) id<STGCTextChannelDelegate> delegate;

@end