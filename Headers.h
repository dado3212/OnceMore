// All necessary TimerManager elements to be able to restart the timer (or create a new one with the same time)
@interface TimerManager
+ (instancetype)sharedManager;
-(double)defaultDuration;
-(NSString *)defaultSound;
-(void)scheduleAt:(double)arg1 withSound:(id)arg2;
@end

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
- (void)_buttonPressed;
@end