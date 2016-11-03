//
//  ViewController.m
//  NotificationsPermissionsAsker
//
//  Created by John Kartupelis on 11/05/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import "ViewController.h"
#import "NotificationsPermissionsHandler.h"
#import "LocationPermissionsHandler.h"

@interface ViewController ()
{
    NotificationsPermissionsHandler* notificationsPermissionsHandler;
    LocationPermissionsHandler* locationPermissionsHandler;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* spinnerNoti;
@property (weak, nonatomic) IBOutlet UIButton* buttonNoti;
@property (weak, nonatomic) IBOutlet UILabel* labelNoti;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* spinnerLoc;
@property (weak, nonatomic) IBOutlet UIButton* buttonLoc;
@property (weak, nonatomic) IBOutlet UILabel* labelLoc;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //create the new notifications permissions handler.
    notificationsPermissionsHandler = [[NotificationsPermissionsHandler alloc] initWithUserNotificationTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) userDefaults:[NSUserDefaults standardUserDefaults]];
    
    //Set the label value.
    [self setNotificationsLabelValue];
    
    //create the new location permissions handler
    locationPermissionsHandler = [[LocationPermissionsHandler alloc] initWithAuthorisationType:kCLAuthorizationStatusAuthorizedAlways];
    
    //set the label value
    [self setLocationPermissionsLabelValue];
}

#pragma mark - Notifications Permissions
-(IBAction)requestNotificationPermissions:(id)sender
{
    if(!notificationsPermissionsHandler.hasRequestedPermissions)
    {
        [[self spinnerNoti] startAnimating];
        [notificationsPermissionsHandler requestPermissionsWithCompletionBlock:^(BOOL success) {
            [[self spinnerNoti] stopAnimating];
            [self setNotificationsLabelValue];
            if(success) {
                UILocalNotification* notification = [[UILocalNotification alloc] init];
                [notification setFireDate:[NSDate date]];
                [notification setAlertTitle:@"Notifications enabled!"];
                [notification setAlertBody:@"notifications have been enabled for the application"];
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Already asked for notification permissions" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

-(void)setNotificationsLabelValue
{
    if(notificationsPermissionsHandler.hasRequestedPermissions)
    {
        if(notificationsPermissionsHandler.hasPermissions)
        {
            self.labelNoti.text = @"Permissions granted";
            self.labelNoti.textColor = [UIColor greenColor];
        }
        else
        {
            self.labelNoti.text = @"Permissions denied";
            self.labelNoti.textColor = [UIColor redColor];
        }
    }
    else
    {
        self.labelNoti.text = @"Permissions not requested";
        self.labelNoti.textColor = [UIColor lightGrayColor];
    }
}


#pragma mark - Location Permissions
-(IBAction)requestLocationPermissions:(id)sender
{
    if(!locationPermissionsHandler.hasRequestedPermissions)
    {
        [[self spinnerLoc] startAnimating];
        [locationPermissionsHandler requestPermissionsWithCompletionBlock:^(BOOL success){
            [[self spinnerLoc] stopAnimating];
            [self setLocationPermissionsLabelValue];
        }];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Already asked for location permissions" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

-(void)setLocationPermissionsLabelValue
{
    if(locationPermissionsHandler.hasRequestedPermissions)
    {
        if(locationPermissionsHandler.hasPermissions)
        {
            self.labelLoc.text = @"Permissions granted";
            self.labelLoc.textColor = [UIColor greenColor];
        }
        else
        {
            self.labelLoc.text = @"Permissions denied";
            self.labelLoc.textColor = [UIColor redColor];
        }
    }
    else
    {
        self.labelLoc.text = @"Permissions not requested";
        self.labelLoc.textColor = [UIColor lightGrayColor];
    }
}

@end
