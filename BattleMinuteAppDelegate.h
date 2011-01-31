//
//  BattleMinuteAppDelegate.h
//  BattleMinute
//
//  Created by Jeremy Foo on 8/7/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>

@interface BattleMinuteAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSWindow *loginWindow;
	SUUpdater *sparkle;
}
@property (assign) IBOutlet SUUpdater *sparkle;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *loginWindow;
-(NSString *)installationId;
@end
