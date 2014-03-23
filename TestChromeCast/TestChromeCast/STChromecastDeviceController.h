//
//  STChromecastDeviceController.h
//  TestChromeCast
//
//  Created by Salmo Roberto da Silva Junior on 17/02/14.
//  Copyright (c) 2014 Salmo Roberto da Silva Junior. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleCast/GoogleCast.h>

/**
 * The delegate to ChromecastDeviceController. Allows responsding to device and
 * media states and reflecting that in the UI.
 */
@protocol STChromecastControllerDelegate<NSObject>

@optional

/**
 * Called when chromecast devices are discoverd on the network.
 */
- (void)didDiscoverDeviceOnNetwork;

/**
 * Called when connection to the device was established.
 *
 * @param device The device to which the connection was established.
 */
- (void)didConnectToDevice:(GCKDevice*)device;

/**
 * Called when connection to the device was closed.
 */
- (void)didDisconnect;

/**
 * Called when the playback state of media on the device changes.
 */
- (void)didReceiveMediaStateChange;

/**
 * Called to display the modal device view controller from the cast icon.
 */
- (void)shouldDisplayModalDeviceController;

/**
 * Called to display the remote media playback view controller.
 */
- (void)shouldPresentPlaybackController;

/**
 * Called when device send when media to chromecast.
 */
- (void)sendMedia;

/**
 * Called when receive message from chromecast.
 */
- (void)didReceiveTextMessage:(NSString *)message;

@end

@interface STChromecastDeviceController : NSObject <GCKDeviceScannerListener, GCKDeviceManagerDelegate, GCKMediaControlChannelDelegate>

/** The delegate attached to this controller. */
@property(nonatomic, assign) id<STChromecastControllerDelegate> delegate;

/** The device scanner used to detect devices on the network. */
@property(nonatomic, strong) GCKDeviceScanner* deviceScanner;

/** The device manager used to manage conencted chromecast device. */
@property(nonatomic, strong) GCKDeviceManager* deviceManager;

/** The UIButton denoting the chromecast device. */
@property(nonatomic, strong) UIBarButtonItem* chromecastButton;

/** Perform a device scan to discover devices on the network. */
- (void)performScan:(BOOL)start;

/** Connect to a specific Chromecast device. */
- (void)connectToDevice:(GCKDevice*)device;

/** Disconnect from a Chromecast device. */
- (void)disconnectFromDevice;

/** Returns true if connected to a Chromecast device. */
- (BOOL)isConnected;

/** Load a media on the device with supplied media metadata. */
- (BOOL)loadMedia:(NSURL *)url
     thumbnailURL:(NSURL *)thumbnailURL
            title:(NSString *)title
         subtitle:(NSString *)subtitle
         mimeType:(NSString *)mimeType;

/** Returns true if connected to a Chromecast device. */
- (void)sendMessage:(NSString *)message;

@end
