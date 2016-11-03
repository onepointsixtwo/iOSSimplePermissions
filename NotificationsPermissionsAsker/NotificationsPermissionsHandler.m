//
//  NotificationsPermissionsHandler.m
//  NotificationsPermissionsAsker
//
//  Created by John Kartupelis on 11/05/2016.
//  Copyright © 2016 John Kartupelis. All rights reserved.
//

#import "NotificationsPermissionsHandler.h"

const NSString* kAskedPermissionsForUserNotificationsKey = @"kAskedPermissionsForUserNotificationsKey";
const NSTimeInterval kTimeoutInterval = 1.0f;

@interface NotificationsPermissionsHandler ()
{
    BOOL waitingToResignActive;
    BOOL waitingToBecomeActive;
    NSTimer* timeoutTimer;
}

@property (strong, nonatomic) NSUserDefaults* userDefaults;
@property (nonatomic) UIUserNotificationType types;
@property (nonatomic, copy, nullable) void (^completionBlock)(BOOL);

@end

@implementation NotificationsPermissionsHandler

#pragma mark - Initialisation / Destruction
-(instancetype)initWithUserNotificationTypes:(UIUserNotificationType)types userDefaults:(NSUserDefaults*)userDefaults
{
    if(self = [super init])
    {
        self.types = types;
        self.userDefaults = userDefaults;
        [self initialise];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initialise
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}


#pragma mark - App lifecycle notifications handling
-(IBAction)applicationWillResignActive:(id)sender
{
    waitingToResignActive = FALSE;
    [self cancelTimeoutHandler];
}

-(IBAction)applicationDidBecomeActive:(id)sender
{
    if(waitingToBecomeActive)
    {
        waitingToBecomeActive = FALSE;
        [self callCompletionBlock];
    }
}

#pragma mark - Accessors
-(BOOL)hasRequestedPermissions
{
    UIUserNotificationSettings* settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    UIUserNotificationType types = settings.types;
    if(types != UIUserNotificationTypeNone || [[self userDefaults] boolForKey:(NSString*)kAskedPermissionsForUserNotificationsKey])
    {
        return TRUE;
    }
    return FALSE;
}

-(BOOL)hasPermissions
{
    UIUserNotificationSettings* settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    UIUserNotificationType types = settings.types;
    if((types & self.types) != self.types)
    {
        return FALSE;
    }
    return TRUE;
}


#pragma mark - Public Methods
-(void)requestPermissionsWithCompletionBlock:(void (^)(BOOL))completionBlock
{
    //Set the completion block.
    self.completionBlock = completionBlock;
    
    //Setup state
    waitingToResignActive = TRUE;
    waitingToBecomeActive = TRUE;
    
    //Register for remote notifications
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    //Ask for permissions
    UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:self.types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    //Set to having asked for permissions
    [[self userDefaults] setBool:TRUE forKey:(NSString*)kAskedPermissionsForUserNotificationsKey];
    
    //Start the timeout
    [self startTimeoutHandler];
}


#pragma mark - Helpers
-(void)callCompletionBlock
{
    if(self.completionBlock != nil)
    {
        self.completionBlock(self.hasPermissions);
        self.completionBlock = nil;
    }
}


#pragma mark - Timeout handling
-(void)startTimeoutHandler
{
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeoutInterval target:self selector:@selector(timeout:) userInfo:nil repeats:FALSE];
}

-(IBAction)timeout:(id)sender
{
    if(waitingToResignActive)
    {
        waitingToResignActive = FALSE;
        waitingToBecomeActive = FALSE;
        [self callCompletionBlock];
    }
}

-(void)cancelTimeoutHandler
{
    if(timeoutTimer)
    {
        [timeoutTimer invalidate];
    }
}

@end
