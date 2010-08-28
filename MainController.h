//
//  MainController.h
//  BattleMinute
//
//  Created by Jeremy Foo on 8/27/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JONTUSemester.h"

@interface MainController : NSObject <NSWindowDelegate> {
	NSWindow *window;
	NSWindow *loginWindow;
	NSWindow *progressWindow;
	
	NSTextField *progressDescription;
	NSProgressIndicator *progressProgressIndicator;
	
	NSTextField *loginUser;
	NSTextField *loginPassword;
	NSTextField *loginDomain;
	NSButton *loginButton;
	
	NSArrayController *semesterArrayController;
	id currentlySelectedItem;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *loginWindow;
@property (assign) IBOutlet NSWindow *progressWindow;

@property (assign) IBOutlet NSTextField *progressDescription;
@property (assign) IBOutlet NSProgressIndicator *progressProgressIndicator;

@property (assign) IBOutlet NSTextField *loginUser;
@property (assign) IBOutlet NSTextField *loginPassword;
@property (assign) IBOutlet NSTextField *loginDomain;
@property (assign) IBOutlet NSButton *loginButton;

@property (assign) IBOutlet NSArrayController *semesterArrayController;
@property (assign) id currentlySelectedItem;
-(IBAction)getSemesters:(id)sender;
-(IBAction)test:(id)sender;
@end
