//
//  MainController.m
//  BattleMinute
//
//  Created by Jeremy Foo on 8/27/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import "MainController.h"
#import <CalendarStore/CalendarStore.h>

@implementation MainController

@synthesize window, progressWindow, loginWindow,additionalOptionsWindow;
@synthesize progressDescription, progressProgressIndicator;
@synthesize loginUser, loginPassword, loginDomain, loginButton, loginCancelButton, loginSpinner, loginStatus;
@synthesize semesterArrayController, calendarArrayController, semselect ,calselect;

-(void)awakeFromNib {
	[calendarArrayController setContent:[[CalCalendarStore defaultCalendarStore] calendars]];
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
	[self dismissSheet:loginWindow sender:sender];
	[NSApp terminate:sender];
}
-(IBAction)closeAdditionalOptions:(id)sender {
	[self dismissSheet:additionalOptionsWindow sender:sender];
}

-(void)dismissSheet:(NSWindow *)win sender:(id)sender {
	[NSApp endSheet:win];
	[win orderOut:sender];
}

-(void)exportSemester:(JONTUSemester *)sem toCalendar:(CalCalendar *)cal {
	
}

-(IBAction)exportToiCal:(id)sender {
	// lets do some checking
	if (([semselect indexOfSelectedItem] > -1) && (![[calselect stringValue] isEqualToString:@""])) {
		CalCalendar *inputCal;
		
		if ([calselect indexOfSelectedItem] < 0) {
			inputCal = [CalCalendar calendar];
			inputCal.title = [calselect stringValue];
			
		} else {
			// set inputcal to the one that is selected
			inputCal = [[calendarArrayController arrangedObjects] objectAtIndex:[calselect indexOfSelectedItem]];
		}
		
		
		//create shit here.
		NSLog(@"%@",[[[semesterArrayController selectedObjects] objectAtIndex:0] courses]);
		[NSApp beginSheet:additionalOptionsWindow modalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
	
	} else {
		NSString *alertstring = nil;
		
		if (([semselect indexOfSelectedItem] < 0) && ([[calselect stringValue] isEqualToString:@""])) {
			alertstring = @"Please make sure you have selected a semester to export as well as a calendar to export to.";
		} else if ([semselect indexOfSelectedItem] < 0) {
			alertstring = @"Please make sure you have selected a semester to export.";
		} else if ([[calselect stringValue] isEqualToString:@""]) {
			alertstring = @"Please make sure you have selected a calendar to export to.";
		}
		
		
		NSAlert *aha = [NSAlert alertWithMessageText:@"Invalid options"
									   defaultButton:@"OK"
									 alternateButton:nil 
										 otherButton:nil 
						   informativeTextWithFormat:alertstring];

		[aha beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
	}
}


-(IBAction)getSemesters:(id)sender {
	[loginButton setEnabled:NO];
	[loginCancelButton setEnabled:NO];
	[loginUser setEnabled:NO];
	[loginPassword setEnabled:NO];
	[loginSpinner startAnimation:sender];
	[loginStatus setHidden:YES];	
	
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	NSBlockOperation *blockop = [NSBlockOperation blockOperationWithBlock:^{
		NSArray *test = [[JONTUSemester listSemestersOfUser:[loginUser stringValue] password:[loginPassword stringValue] domain:@"STUDENT" parseImmediately:YES] retain];
		
		if (test) {
			[self dismissSheet:loginWindow sender:sender];
						
			[semesterArrayController setContent:test];
		} else {
			[loginButton setEnabled:YES];
			[loginCancelButton setEnabled:YES];
			[loginUser setEnabled:YES];
			[loginPassword setEnabled:YES];
			[loginPassword selectText:sender];
			[loginStatus setHidden:NO];
			[loginStatus setStringValue:@"Login failed"];

		}
		[loginSpinner stopAnimation:sender];

		[test release];
	}];
	[queue addOperation:blockop];
	[queue release];
}

-(void)dealloc {
	[calenders release], calenders = nil;
	[super dealloc];
}

@end
