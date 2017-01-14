#import <objc/runtime.h>
#import "Headers.h"

// Handle not adding reset button twice
static char const * const resetKey = "buttonExists";
// Keep track of the current duration
static double duration = 0;

static void restartTimer() {
	TimerManager *timeManager = [%c(TimerManager) sharedManager];
	if (duration == 0) {
		duration = [timeManager defaultDuration];
	}
	[timeManager scheduleAt:CFAbsoluteTimeGetCurrent() + duration withSound:[timeManager defaultSound]];
}

// Hook to store the most recent timer duration
%hook TimerManager
+(BOOL)isTimerNotification:(id)arg1  {
	BOOL a = %orig;
	if (a) {
		UIConcreteLocalNotification *notification = (UIConcreteLocalNotification *)arg1;
		NSDate *pendingDate = [notification fireDate];
		NSTimeInterval secondsBetweenNowAndFireDate = [pendingDate timeIntervalSinceDate:[NSDate date]];
		duration = round(secondsBetweenNowAndFireDate);
	}
	return a;
}
%end

// Hook to add the restart button to the alert
%hook SBBulletinModalAlert
-(SBBulletinModalAlert *)initWithBulletin:(BBBulletin *)bulletin supersededAlert:(id)arg2  {
	SBBulletinModalAlert *alert = %orig;
	if ([[bulletin section] isEqualToString:@"com.apple.mobiletimer"] && [bulletin sectionSubtype] == 2) { // hopefully just the timer
		// Create restart action
		BBAction *restartAction = [%c(BBAction) actionWithIdentifier:@"com.hackingdartmouth.oncemore.restart"];
	  BBAppearance *appearance = [%c(BBAppearance) appearanceWithTitle:@"Restart"];
		[appearance setColor:(BBColor *)[%c(BBColor) colorWithRed:99.f/255.f green:235.f/255.f blue:31.f/255.f alpha:1.0]];
		[restartAction setAppearance:appearance];
		[restartAction setActionType:2];
		[alert setActions:@[[alert _dismissAction], restartAction]];
	}
	return alert;
}

-(void)_handleAction:(id)action atIndex:(long long)arg2 {
	// Handle custom action to restart timer
	if ([[action identifier] isEqualToString:@"com.hackingdartmouth.oncemore.restart"]) {
		restartTimer();
	}
	%orig;
}
%end

// Hook to add the restart button to the lock screen
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
	restartTimer();
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
		BBBulletin *bulletin = [[[self delegate] bulletinItem] activeBulletin];
		if (button != nil && ([[bulletin section] isEqualToString:@"com.apple.mobiletimer"] && [bulletin sectionSubtype] == 2)) { // It's the timer overlay
			// Copy the old button to match styling
			NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:button];
			UIButton *buttonCopy = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
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

			// Resize for the new label, center it, and move it down a bit
			[buttonCopy sizeToFit];
			buttonCopy.frame = CGRectMake(
				buttonCopy.frame.origin.x + button.frame.size.width / 2 - buttonCopy.frame.size.width / 2, 
				button.frame.origin.y + button.frame.size.height, 
				buttonCopy.frame.size.width, 
				buttonCopy.frame.size.height
			);

			[[self subviews][0] addSubview:buttonCopy];
			[self setButtonExists:true];
		}
	}
	return;
}
%end