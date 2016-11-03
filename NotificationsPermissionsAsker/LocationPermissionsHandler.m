//
//  LocationPermissionsHandler.m
//  NotificationsPermissionsAsker
//
//  Created by John Kartupelis on 17/05/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import "LocationPermissionsHandler.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LocationPermissionsHandler () <CLLocationManagerDelegate>

@property (nonatomic) CLAuthorizationStatus authorisationTypeRequired;
@property (nonatomic) CLLocationManager* locationManager;
@property (nonatomic, copy, nullable) void (^completionBlock)(BOOL);

@end


@implementation LocationPermissionsHandler


#pragma mark - Initialisation
-(instancetype)initWithAuthorisationType:(CLAuthorizationStatus)authorisationTypeRequired
{
    if(self = [super init])
    {
        self.authorisationTypeRequired = authorisationTypeRequired;
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        NSAssert(authorisationTypeRequired == kCLAuthorizationStatusAuthorizedAlways || authorisationTypeRequired == kCLAuthorizationStatusAuthorizedWhenInUse, @"initWithAuthorisationType: required type must be either always or when in use authorisation");
    }
    return self;
}

#pragma mark - Accessors
-(BOOL)hasRequestedPermissions
{
    return [CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined;
}

-(BOOL)hasPermissions
{
    return CLLocationManager.authorizationStatus == self.authorisationTypeRequired;
}

#pragma mark - Public Methods
-(void)requestPermissionsWithCompletionBlock:(void (^)(BOOL))completionBlock
{
    //assign the completion block.
    self.completionBlock = completionBlock;
    
    //request the permissions.
    if(self.authorisationTypeRequired == kCLAuthorizationStatusAuthorizedAlways)
    {
        [[self locationManager] requestAlwaysAuthorization];
    }
    else
    {
        [[self locationManager] requestWhenInUseAuthorization];
    }
}

#pragma mark - CLLocationManager delegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager:didFailWithError:%@", error.description);
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //ignore if state hasn't changed.
    if(status == kCLAuthorizationStatusNotDetermined) return;
    
    if(self.completionBlock != nil)
    {
        self.completionBlock(self.hasPermissions);
        self.completionBlock = nil;
    }
}

@end
