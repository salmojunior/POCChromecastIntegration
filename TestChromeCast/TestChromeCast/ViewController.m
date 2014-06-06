//
//  ViewController.m
//  TestChromeCast
//
//  Created by Salmo Roberto da Silva Junior on 17/02/14.
//  Copyright (c) 2014 Salmo Roberto da Silva Junior. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "STChromecastDeviceController.h"

@interface ViewController () <STChromecastControllerDelegate> {
    __weak STChromecastDeviceController *_chromecastController;
}
@property (weak, nonatomic) IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *fullscreenButton;
@property (weak, nonatomic) IBOutlet UIButton *volumeButton;
@property (weak, nonatomic) IBOutlet UITextView *responseTextView;
@property (weak, nonatomic) IBOutlet UILabel *responseLabel;
@property (weak, nonatomic) IBOutlet UISlider *videoProgress;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (assign, nonatomic) BOOL isPlaying;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setTitle:@"Chromecast"];
    
    self.controlsView.layer.cornerRadius = 5.0f;
    self.controlsView.layer.masksToBounds = YES;
    self.volumeSlider.value = 100.0f;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self controls:NO];
    
    // Store a reference to the chromecast controller.
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _chromecastController = delegate.chromecastDeviceController;
    
    self.navigationItem.rightBarButtonItem = _chromecastController.chromecastButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Assign ourselves as delegate ONLY in viewWillAppear of a view controller.
    _chromecastController.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [_chromecastController performScan:NO];
}

- (void)sendMedia:(NSString *)videoId provider:(NSString *)providerName
{
    self.isPlaying = NO;
    [self.playButton setSelected:YES];
    [self.fullscreenButton setSelected:YES];
    NSDictionary *dicVideo = @{@"providerName":providerName,@"videoId":videoId};
    NSString *jsonVideo = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dicVideo options:0 error:nil] encoding:NSUTF8StringEncoding];
    [_chromecastController sendMessage:jsonVideo];
}

- (IBAction)sendYoutubeVideo:(id)sender {
    self.videoProgress.maximumValue = 493.0f;
    [self sendMedia:@"A72DaaXBVAA" provider:@"youtube"];
}

- (IBAction)sendYoutubeTwo:(id)sender {
    self.videoProgress.maximumValue = 163.0f;
    [self sendMedia:@"9paiXACqels" provider:@"youtube"];
}

- (IBAction)playMedia:(UIButton *)sender {
    if ([sender isSelected]) {
        [_chromecastController sendMessage:@"pause"];
        [sender setSelected:NO];
    } else {
        [_chromecastController sendMessage:@"play"];
        [sender setSelected:YES];
    }
}

- (IBAction)sendMute:(UIButton *)sender {
    if ([sender isSelected]) {
        [_chromecastController sendMessage:@"unmute"];
        [sender setSelected:NO];
    } else {
        [_chromecastController sendMessage:@"mute"];
        [sender setSelected:YES];
    }
}

- (IBAction)sendFullscreen:(UIButton *)sender {
    if ([sender isSelected]) {
        [_chromecastController sendMessage:@"endfullscreen"];
        [sender setSelected:NO];
    } else {
        [_chromecastController sendMessage:@"fullscreen"];
        [sender setSelected:YES];
    }
}

- (void)controls:(BOOL)showControls
{
    if (showControls) {
        [self.playButton setSelected:NO];
        [self.fullscreenButton setSelected:NO];
        
        self.responseLabel.hidden = NO;
        self.controlsView.hidden = NO;
        [self.responseTextView setText:@""];
    } else {
        self.controlsView.hidden = YES;
        self.responseLabel.hidden = YES;
    }
}

- (IBAction)videoProgressChanges:(id)sender
{
    self.isPlaying = NO;
    NSInteger seekTo = ceil(self.videoProgress.value);
    NSString *valueString = [NSString stringWithFormat:@"%d", seekTo];
    NSDictionary *dicProgress = @{@"seekto":valueString};
    NSString *jsonProgress= [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dicProgress options:0 error:nil] encoding:NSUTF8StringEncoding];
    [_chromecastController sendMessage:jsonProgress];
}

- (IBAction)volumeChanges:(id)sender
{
    NSInteger volume = self.volumeSlider.value;
    if (volume != 0) {
        [_chromecastController sendMessage:@"unmute"];
        [self.volumeButton setSelected:NO];
    }
    
    NSString *valueString = [NSString stringWithFormat:@"%d", volume];
    NSDictionary *dicVolume = @{@"setvolume":valueString};
    NSString *jsonVolume = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dicVolume options:0 error:nil] encoding:NSUTF8StringEncoding];
    [_chromecastController sendMessage:jsonVolume];
}

#pragma mark - ChromecastControllerDelegate

/**
 * Called to display the modal device view controller from the cast icon.
 */
- (void)shouldDisplayModalDeviceController
{
    if (_chromecastController.isConnected) {
        [self controls:NO];
        [_chromecastController sendMessage:@"disconnect"];
        [_chromecastController disconnectFromDevice];
        [self.playButton setSelected:NO];
        [self.fullscreenButton setSelected:NO];
        self.videoProgress.value = 0;
        [self.responseTextView setText:@""];
    } else {
        [self performSegueWithIdentifier:@"chromecastConnect" sender:self];
    }
}

/**
 * Called when chromecast devices are discoverd on the network.
 */
- (void)didDiscoverDeviceOnNetwork {
//    [self enableButton];
}

- (void)didConnectToDevice:(GCKDevice*)device
{
    [self controls:YES];
}

- (void)didReceiveTextMessage:(NSString *)message
{
    NSMutableString *messagesBkp = [[NSMutableString alloc] initWithString:message];
    
    if (![self.responseTextView.text isEqualToString:@""]) {
        [messagesBkp appendString:[NSString stringWithFormat:@"\n%@", self.responseTextView.text]];
    }
    
    self.responseTextView.text = messagesBkp;
    self.responseTextView.font = [UIFont systemFontOfSize:16.0f];
    
    if ([message isEqualToString:@"Video Playing."]) {
        [self.playButton setSelected:YES];
        self.isPlaying = YES;
    }
    
    if ([message isEqualToString:@"The video was paused."]) {
        [self.playButton setSelected:NO];
        self.isPlaying = NO;
    }
    
    if ([message isEqualToString:@"Video Ended."]) {
        [self.playButton setSelected:NO];
        self.isPlaying = NO;
        self.videoProgress.value = 0;
        [self.fullscreenButton setSelected:NO];
    }
    
    if ([message isEqualToString:@"This video has an error."]) {
        [self.playButton setSelected:NO];
    }
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *messageDic = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error:nil];
    
    if (messageDic[@"currentTime"])
    {
        if (self.isPlaying) {
            NSInteger currentTime = [messageDic[@"currentTime"] integerValue];
            self.videoProgress.value = currentTime;
        }
    }
    
    if ([message isEqualToString:@"Another sender is in control."]) {
        [self.playButton setSelected:NO];
    }
}

@end
