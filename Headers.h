// All necessary TimerManager elements to be able to restart the timer (or create a new one with the same time)
@interface TimerManager
+ (instancetype)sharedManager;
-(double)defaultDuration;
-(NSString *)defaultSound;
-(void)scheduleAt:(double)arg1 withSound:(id)arg2;
@end

/*
  _   ____    _____    ___  
 (_) / __ \  / ____|  / _ \ 
  _ | |  | || (___   | (_) |
 | || |  | | \___ \   \__, |
 | || |__| | ____) |    / / 
 |_| \____/ |_____/    /_/  
                            
*/

// Keep duration up to date
@interface UIConcreteLocalNotification
-(id)fireDate;
@end

// All necessary SBBulletinModalAlert elements to be able to add the 'restart' alert option
@interface SBBulletinModalAlert
@property (nonatomic,retain) NSArray * buttons;
-(id)_dismissAction;
-(void)setActions:(NSArray *)arg1 ;
-(void)setButtons:(NSArray *)arg1 ;
@end

@interface BBAction
+(id)actionWithIdentifier:(id)arg1 ;
-(NSString *)identifier;
-(void)setAppearance:(id)arg1 ;
-(void)setActionType:(long long)arg1 ;
@end

@interface BBAppearance
+(id)appearanceWithTitle:(id)arg1 ;
-(void)setColor:(id)arg1 ;
@end

@interface BBBulletin
-(NSString *)section;
-(long long)sectionSubtype;
@end

// All necessary SBUILockOverlayView elements to be able to add the 'restart' button
@interface SBUILockOverlayView : UIView
@property (readwrite) BOOL buttonExists;
@property (nonatomic,readonly) UIButton * actionButton;  
-(void)_buttonPressed;
-(id)delegate;
@end

@interface SBAwayBulletinListItem
-(BBBulletin *)activeBulletin;
@end

@interface SBLockScreenFullscreenBulletinViewController
@property (nonatomic,retain) SBAwayBulletinListItem * bulletinItem;
@end

/*
  _   ____    _____   __   ___  
 (_) / __ \  / ____| /_ | / _ \ 
  _ | |  | || (___    | || | | |
 | || |  | | \___ \   | || | | |
 | || |__| | ____) |  | || |_| |
 |_| \____/ |_____/   |_| \___/ 

*/
@interface NCNotificationRequest : NSObject
@property (nonatomic,copy,readonly) NSString* sectionIdentifier;
@property (nonatomic,readonly) BBBulletin* bulletin;
@end

@interface SBDashBoardModalView : UIView
-(void)setSecondaryActionButtonText:(NSString *)arg1;
@end

@interface UIInterfaceAction : NSObject
+(id)actionWithTitle:(id)arg1 type:(long long)arg2 handler:(/*^block*/id)arg3 ;
-(id)handler;
@end

@interface _NCNotificationViewControllerView : UIView
-(id)contentView;
@end

@interface NCNotificationLongLookView : UIView
-(void)setInterfaceActions:(NSArray *)arg1;
-(NSArray *)interfaceActions;
@end

@interface NCNotificationLongLookViewController : UIViewController
@property (nonatomic,retain) NCNotificationRequest * notificationRequest;
@end

@interface SBDashBoardFullscreenNotificationViewController : UIViewController
@property (nonatomic,readonly) NCNotificationRequest* notificationRequest;
-(void)handlePrimaryActionForView:(id)arg1;
@end