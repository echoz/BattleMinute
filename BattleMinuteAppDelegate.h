//
//  BattleMinuteAppDelegate.h
//  BattleMinute
//
//  Created by Jeremy Foo on 8/7/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BattleMinuteAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSWindow *loginWindow;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *loginWindow;

@end
