//
//  AppDelegate.h
//  TestChromeCast
//
//  Created by Salmo Roberto da Silva Junior on 17/02/14.
//  Copyright (c) 2014 Salmo Roberto da Silva Junior. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleCast/GoogleCast.h>
#import "STChromecastDeviceController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, GCKLoggerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property STChromecastDeviceController *chromecastDeviceController;

@end
