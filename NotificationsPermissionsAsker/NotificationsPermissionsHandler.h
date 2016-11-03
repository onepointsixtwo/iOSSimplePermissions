//
//  NotificationsPermissionsHandler.h
//  NotificationsPermissionsAsker
//
//  Created by John Kartupelis on 11/05/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NotificationsPermissionsHandler : NSObject

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithUserNotificationTypes:(UIUserNotificationType)types userDefaults:(NSUserDefaults*)userDefaults NS_DESIGNATED_INITIALIZER;
@property (readonly, nonatomic) BOOL hasRequestedPermissions;
@property (readonly, nonatomic) BOOL hasPermissions;
-(void)requestPermissionsWithCompletionBlock:(void(^)(BOOL success))completionBlock;

@end
