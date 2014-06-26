//
//  STChromecastDeviceController.m
//  TestChromeCast
//
//  Created by Salmo Roberto da Silva Junior on 17/02/14.
//  Copyright (c) 2014 Salmo Roberto da Silva Junior. All rights reserved.
//

#import "STChromecastDeviceController.h"
#import "STGCTextChannel.h"

static NSString *const kReceiverAppID = @"76F86A93";

@interface STChromecastDeviceController () <STGCTextChannelDelegate>

@property GCKMediaControlChannel *mediaControlChannel;
@property GCKApplicationMetadata *applicationMetadata;
@property GCKDevice *selectedDevice;
@property STGCTextChannel *castChannel;

@end

@implementation STChromecastDeviceController

- (id)init {
    self = [super init];
    if (self) {
        // Initialize device scanner
        self.deviceScanner = [[GCKDeviceScanner alloc] init];
        self.castChannel = [[STGCTextChannel alloc] initWithNamespace:@"urn:x-cast:StashAppTest"];
        [self.castChannel setDelegate:self];
        // Initialize UI controls for navigation bar and tool bar.
        [self initControls];
    }
    return self;
}

- (void)performScan:(BOOL)start {
    
    if (start) {
        [self.deviceScanner addListener:self];
        [self.deviceScanner startScan];
    } else {
        [self.deviceScanner stopScan];
        [self.deviceScanner removeListener:self];
    }
}

- (void)connectToDevice:(GCKDevice *)device {
    self.selectedDevice = device;
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appIdentifier = [info objectForKey:@"CFBundleIdentifier"];
    self.deviceManager =
    [[GCKDeviceManager alloc] initWithDevice:self.selectedDevice clientPackageName:appIdentifier];
    self.deviceManager.delegate = self;
    [self.deviceManager connect];
}

- (void)disconnectFromDevice {
    NSLog(@"Disconnecting device:%@", self.selectedDevice.friendlyName);
    // New way of doing things: We're not going to stop the applicaton. We're just going to leave it.
    [self.deviceManager leaveApplication];
    // If you want to force application to stop, uncomment below
    [self.deviceManager disconnect];
}

- (BOOL)isConnected {
    return self.deviceManager.isConnected;
}

- (BOOL)loadMedia:(NSURL *)url
     thumbnailURL:(NSURL *)thumbnailURL
            title:(NSString *)title
         subtitle:(NSString *)subtitle
         mimeType:(NSString *)mimeType {
    
    if (!self.deviceManager || !self.deviceManager.isConnected) {
        return NO;
    }
    
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] init];
    
    [metadata setString:title forKey:kGCKMetadataKeyTitle];
    [metadata setString:subtitle forKey:kGCKMetadataKeySubtitle];
    [metadata addImage:[[GCKImage alloc] initWithURL:thumbnailURL width:200 height:100]];
    
    GCKMediaInformation *mediaInformation =
    [[GCKMediaInformation alloc] initWithContentID:[url absoluteString]
                                        streamType:GCKMediaStreamTypeNone
                                       contentType:mimeType
                                          metadata:metadata
                                    streamDuration:0
                                        customData:nil];
    
    [self.mediaControlChannel loadMedia:mediaInformation];
    
    return YES;
}

- (void)sendMessage:(NSString *)message
{
    [self.castChannel sendTextMessage:message];
}

#pragma mark - implementation

- (void)showError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                    message:NSLocalizedString(error.description, nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (NSString *)getDeviceName {
    if (self.selectedDevice == nil)
        return @"";
    return self.selectedDevice.friendlyName;
}

- (void)initControls {
    UIImage *btnImage = [UIImage imageNamed:@"disconnected"];
    UIImage *btnImageConnected = [UIImage imageNamed:@"cast_solid_custom"];
    
    UIButton *chromecastButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [chromecastButton addTarget:self
                         action:@selector(chooseDevice:)
               forControlEvents:UIControlEventTouchDown];
    chromecastButton.frame = CGRectMake(0, 0, btnImage.size.width, btnImage.size.height);
    
    [chromecastButton setImage:btnImage forState:UIControlStateNormal];
    [chromecastButton setImage:btnImageConnected forState:UIControlStateSelected];
    
    chromecastButton.hidden = YES;
    
    self.chromecastButton = [[UIBarButtonItem alloc] initWithCustomView:chromecastButton];
}

- (void)chooseDevice:(id)sender {
    if ([self.delegate respondsToSelector:@selector(shouldDisplayModalDeviceController)]) {
        [_delegate shouldDisplayModalDeviceController];
    }
}

#pragma mark - GCKDeviceScannerListener
- (void)deviceDidComeOnline:(GCKDevice *)device {
    NSLog(@"device found!! %@", device.friendlyName);
    [self updateCastIconButtonStates];
    if ([self.delegate respondsToSelector:@selector(didDiscoverDeviceOnNetwork)]) {
        [self.delegate didDiscoverDeviceOnNetwork];
    }
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
    [self updateCastIconButtonStates];
}

#pragma mark - GCKDeviceManagerDelegate

- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
    NSLog(@"connected!!");
    [self.deviceManager launchApplication:kReceiverAppID];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApplication {
    
    NSLog(@"application has launched");
    self.mediaControlChannel = [[GCKMediaControlChannel alloc] init];
    self.mediaControlChannel.delegate = self;
//    [self.deviceManager addChannel:self.mediaControlChannel];
    [self.deviceManager addChannel:self.castChannel];
    [self.mediaControlChannel requestStatus];
    
    self.applicationMetadata = applicationMetadata;
    [self updateCastIconButtonStates];
    
    if ([self.delegate respondsToSelector:@selector(didConnectToDevice:)]) {
        [self.delegate didConnectToDevice:self.selectedDevice];
    }
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
didFailToConnectToApplicationWithError:(NSError *)error {
    [self showError:error];
    
    [self deviceDisconnected];
    [self updateCastIconButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
didFailToConnectWithError:(GCKError *)error {
    [self showError:error];
    
    [self deviceDisconnected];
    [self updateCastIconButtonStates];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(GCKError *)error {
    NSLog(@"Received notification that device disconnected");
    
    if (error != nil) {
        [self showError:error];
    }
    
    [self deviceDisconnected];
    [self updateCastIconButtonStates];
    
}

- (void)deviceDisconnected {
    self.mediaControlChannel = nil;
    self.deviceManager = nil;
    self.selectedDevice = nil;
    
    if ([self.delegate respondsToSelector:@selector(didDisconnect)]) {
        [self.delegate didDisconnect];
    }
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didReceiveStatusForApplication:(GCKApplicationMetadata *)applicationMetadata {
    self.applicationMetadata = applicationMetadata;
    NSLog(@"Received device status: %@", applicationMetadata);
}

- (void)updateCastIconButtonStates {
    UIButton *chromecastButton = (UIButton *)self.chromecastButton.customView;
    
    // Hide the button if there are no devices found.
    if (self.deviceScanner.devices.count == 0) {
        chromecastButton.hidden = YES;
    } else {
        chromecastButton.hidden = NO;
        if (self.deviceManager && self.deviceManager.isConnected) {
            // Hilight with yellow tint color.
            [chromecastButton setSelected:YES];
        } else {
            // Remove the hilight.
            [chromecastButton setSelected:NO];
        }
    }
}

#pragma mark - STGCTextChannelDelegate

- (void)didChannelReceiveTextMessage:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(didReceiveTextMessage:)]) {
        [self.delegate didReceiveTextMessage:message];
    }
}

@end
