#import <objc/runtime.h>

// All necessary TimerManager elements to be able to restart the timer (or create a new one with the same time)
@interface TimerManager
+ (instancetype)sharedManager;
-(double)defaultDuration;
-(NSString *)defaultSound;
-(void)scheduleAt:(double)arg1 withSound:(id)arg2;
@end

// All necessary SBUILockOverlayView elements to be able to add the 'restart' button
@interface SBUILockOverlayView : UIView
@property (readwrite) BOOL buttonExists;
@property (nonatomic,readonly) UIButton * actionButton;  
- (void)_buttonPressed;
@end
// Handle not adding reset button twice
static char const * const resetKey = "buttonExists";

%hook SBUILockOverlayView

%new
- (void)setButtonExists:(BOOL)created {
    NSNumber *number = [NSNumber numberWithBool:created];
    objc_setAssociatedObject(self, resetKey, number, OBJC_ASSOCIATION_RETAIN);
}

%new
- (BOOL)buttonExists {
    NSNumber *number = objc_getAssociatedObject(self, resetKey);
    return [number boolValue];
}

%new
-(void)restart {
	// Finish current timer, start new timer with same duration and sound
	[self _buttonPressed];
	TimerManager *timeManager = [%c(TimerManager) sharedManager];
	[timeManager scheduleAt:CFAbsoluteTimeGetCurrent() + [timeManager defaultDuration] withSound:[timeManager defaultSound]];
}

// Initialize set to false
-(id)initWithFrame:(CGRect)arg1 style:(unsigned long long)arg2 {
	[self setButtonExists:false];
	return %orig;
}

// Add the new button if it's the timer overlay
-(void)layoutSubviews {
	%orig;
	if (![self buttonExists]) {
		UIButton *button = [self actionButton];
		if (button != nil && [button.titleLabel.text isEqualToString:@"Tap to stop"]) { // It's the timer overlay
			// Copy the old button to match styling
			NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject: button];
			UIButton *buttonCopy = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
			// Remove all targets
			[buttonCopy removeTarget:nil 
		                   action:NULL 
		         forControlEvents:UIControlEventAllEvents];
			// Add restart target
			[buttonCopy addTarget:self 
			           action:@selector(restart)
			 forControlEvents:UIControlEventTouchUpInside];
			// Change name
			[buttonCopy setTitle:@"Tap to restart" forState:UIControlStateNormal];
			// Move down a little
			buttonCopy.frame = CGRectMake(buttonCopy.frame.origin.x - 20.0, buttonCopy.frame.origin.y + 20.0, buttonCopy.frame.size.width + 40.0, buttonCopy.frame.size.height);
			[[self subviews][0] addSubview:buttonCopy];
			[self setButtonExists:true];
		}
	}
	return;
}
%end