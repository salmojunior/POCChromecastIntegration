//
//  ShowChromecastTableViewController.m
//  TestChromeCast
//
//  Created by Salmo Roberto da Silva Junior on 18/02/14.
//  Copyright (c) 2014 Salmo Roberto da Silva Junior. All rights reserved.
//


#import "ShowChromecastTableViewController.h"
#import "STChromecastDeviceController.h"
#import "AppDelegate.h"

@interface ShowChromecastTableViewController ()

@end

@implementation ShowChromecastTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (STChromecastDeviceController *)castDeviceController {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return delegate.chromecastDeviceController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.castDeviceController.deviceScanner.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    GCKDevice *device = [self.castDeviceController.deviceScanner.devices objectAtIndex:indexPath.row];
    cell.textLabel.text = device.friendlyName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    GCKDevice *device = [self.castDeviceController.deviceScanner.devices objectAtIndex:indexPath.row];
    [self.castDeviceController connectToDevice:device];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
