//
//  MainController.m
//  BattleMinute
//
//  Created by Jeremy Foo on 8/27/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import "MainController.h"
#import <CalendarStore/CalendarStore.h>
#import "JONTUSemesterDates.h"
#import "JONTUCourse.h"
#import "JONTUClass.h"

@implementation MainController

@synthesize window, progressWindow, loginWindow,additionalOptionsWindow;
@synthesize progressDescription, progressProgressIndicator;
@synthesize loginUser, loginPassword, loginDomain, loginButton, loginCancelButton, loginSpinner, loginStatus;
@synthesize semesterArrayController, calendarArrayController, semselect ,calselect;
@synthesize firstDay, recess;

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

-(NSUInteger)maxWeeksForSemester:(JONTUSemester *)sem {
	int max = 0;
	
	for (int i=0;i<[[sem courses] count];i++) {
		for (int j=0;i<[[[[sem courses] objectAtIndex:i] classes] count];j++) {
			if ([[[[[[sem courses] objectAtIndex:i] classes] objectAtIndex:j] activeWeeks] count] > max) {
				max = [[[[[[sem courses] objectAtIndex:i] classes] objectAtIndex:j] activeWeeks] count];
			}
		}
	}
	return max;
}

-(void)exportSemester:(JONTUSemester *)sem toCalendar:(CalCalendar *)cal usingDates:(NSDictionary *)dates {
	[progressDescription setStringValue:@"Begin export to iCal"];
	
	NSUInteger maxWeeks = [self maxWeeksForSemester:sem];
	[progressProgressIndicator setMaxValue:maxWeeks];

	// export logic here
	// 1. find out maximum number of weeks
	// 2. iterate through the monday of each week to find dates
	// 3. add shit in
	// 4. create events and save them
	// 5. save calendar

}

-(IBAction)selectDates:(id)sender {
	[self dismissSheet:additionalOptionsWindow sender:sender];
	[NSApp beginSheet:progressWindow modalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[progressProgressIndicator startAnimation:sender];
	
	NSMutableDictionary *dates = [NSMutableDictionary dictionary];
	[dates setObject:firstDay forKey:@"SEM_START"];
	[dates setObject:recess forKey:@"RECESS_START"];
	CalCalendar *inputCal;
	
	if ([calselect indexOfSelectedItem] < -1) {
		inputCal = [CalCalendar calendar];
		inputCal.title = [calselect stringValue];
		
	} else {
		// set inputcal to the one that is selected
		inputCal = [[calendarArrayController arrangedObjects] objectAtIndex:[calselect indexOfSelectedItem]];
	}
	
	[self exportSemester:[[semesterArrayController selectedObjects] objectAtIndex:0]
			  toCalendar:inputCal 
			  usingDates:dates];
	
}

-(IBAction)exportToiCal:(id)sender {
	// lets do some checking
	if (([semselect indexOfSelectedItem] > -1) && (![[calselect stringValue] isEqualToString:@""]) && ([[[[semesterArrayController selectedObjects] objectAtIndex:0] courses] count] > 0)) {
		CalCalendar *inputCal;
		
		if ([calselect indexOfSelectedItem] < -1) {
			inputCal = [CalCalendar calendar];
			inputCal.title = [calselect stringValue];
			
		} else {
			// set inputcal to the one that is selected
			inputCal = [[calendarArrayController arrangedObjects] objectAtIndex:[calselect indexOfSelectedItem]];
		}
		
		//create shit here.
		[NSApp beginSheet:progressWindow modalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
		[progressProgressIndicator startAnimation:sender];
		[progressDescription setStringValue:@"Attempting to autodetect semester dates"];
		
		
		NSOperationQueue *queue = [[NSOperationQueue alloc] init];
		NSBlockOperation *blockop = [NSBlockOperation blockOperationWithBlock:^{
			JONTUSemesterDates *semdates = [[JONTUSemesterDates alloc] initWithYear:[[[semesterArrayController selectedObjects] objectAtIndex:0] year]];
			[semdates parse];
			
			if ([[semdates semesterWithCode:[[[semesterArrayController selectedObjects] objectAtIndex:0] semester]] count] > 0) {
				
				// autodetected semester dates								
				[self exportSemester:[[semesterArrayController selectedObjects] objectAtIndex:0] 
						  toCalendar:inputCal 
						  usingDates:[semdates semesterWithCode:[[[semesterArrayController selectedObjects] objectAtIndex:0] semester]]];
				
			} else {
				// no autodetect
				[self dismissSheet:progressWindow sender:sender];
				[firstDay setDateValue:[NSDate date]];
				[recess setDateValue:[NSDate date]];
				[NSApp beginSheet:additionalOptionsWindow modalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
			}
			
			[semdates release];
		}];

		[queue addOperation:blockop];
		[queue release];
	
	} else {
		NSString *alertstring = nil;
		
		if ([[[[semesterArrayController selectedObjects] objectAtIndex:0] courses] count] == 0) {
			alertstring = @"Current semester has no courses to be exported";
		} else if (([semselect indexOfSelectedItem] < 0) && ([[calselect stringValue] isEqualToString:@""])) {
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
