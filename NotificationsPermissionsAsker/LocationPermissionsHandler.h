//
//  LocationPermissionsHandler.h
//  NotificationsPermissionsAsker
//
//  Created by John Kartupelis on 17/05/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationPermissionsHandler : NSObject

-(nonnull instancetype)init NS_UNAVAILABLE;
-(nonnull instancetype)initWithAuthorisationType:(CLAuthorizationStatus)authorisationTypeRequired;
@property (readonly, nonatomic) BOOL hasRequestedPermissions;
@property (readonly, nonatomic) BOOL hasPermissions;
-(void)requestPermissionsWithCompletionBlock:(nonnull void(^)(BOOL success))completionBlock;

@end
