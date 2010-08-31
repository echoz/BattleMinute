//
//  MainController.m
//  BattleMinute
//
//  Created by Jeremy Foo on 8/27/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import "MainController.h"

@implementation MainController

@synthesize window, progressWindow, loginWindow;
@synthesize progressDescription, progressProgressIndicator;
@synthesize loginUser, loginPassword, loginDomain, loginButton, loginCancelButton, loginSpinner;
@synthesize semesterArrayController, semselect;

-(void)awakeFromNib {

}

-(BOOL)windowShouldClose:(id)sender {
	[NSApp terminate:sender];
	return YES;
}

-(void)windowDidBecomeMain:(NSNotification *)notification {
	if (([notification object] == window) && ([[semesterArrayController arrangedObjects] count] == 0)) {
		[NSApp beginSheet:loginWindow modalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
	}
}
-(IBAction)quit:(id)sender {
	[NSApp endSheet:loginWindow];
	[loginWindow orderOut:sender];
	[NSApp terminate:sender];
}


-(IBAction)getSemesters:(id)sender {
	[loginButton setEnabled:NO];
	[loginCancelButton setEnabled:NO];
	[loginSpinner startAnimation:sender];
	 
	NSArray *test = [[JONTUSemester listSemestersOfUser:[loginUser stringValue] password:[loginPassword stringValue] domain:@"STUDENT" parseImmediately:YES] retain];
	
	if (test) {
		[NSApp endSheet:loginWindow];
		[loginWindow orderOut:sender];
		
		[semesterArrayController setContent:test];
	} else {
		[loginButton setEnabled:YES];
		[loginCancelButton setEnabled:YES];
		[loginSpinner stopAnimation:sender];
	}
	[test release];
}

@end
