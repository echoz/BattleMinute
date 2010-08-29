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
@synthesize loginUser, loginPassword, loginDomain, loginButton;
@synthesize semesterArrayController,currentlySelectedItem;

-(void)awakeFromNib {

}

-(void)windowDidBecomeMain:(NSNotification *)notification {
	if (([notification object] == window) && ([[semesterArrayController arrangedObjects] count] == 0)) {
		[NSApp beginSheet:loginWindow modalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
	}
}
-(IBAction)test:(id)sender {
	NSLog(@"%@", currentlySelectedItem);
}
-(IBAction)getSemesters:(id)sender {
	NSArray *test = [[JONTUSemester listSemestersOfUser:[loginUser stringValue] password:[loginPassword stringValue] domain:@"STUDENT" parseImmediately:YES] retain];
	
	if (test) {
		[NSApp endSheet:loginWindow];
		[loginWindow orderOut:sender];
		
		[semesterArrayController setContent:test];
		[semesterArrayController setSelectionIndex:1];
		[semesterArrayController arrangedObjects];
	}
	[test release];
}

@end
