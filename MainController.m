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
#import "JONTUSemester.h"
#import "JONTUCourse.h"
#import "JONTUClass.h"

@implementation MainController

@synthesize window, progressWindow, loginWindow,additionalOptionsWindow;
@synthesize progressDescription, progressProgressIndicator;
@synthesize loginUser, loginPassword, loginDomain, loginButton, loginCancelButton, loginSpinner, loginStatus;
@synthesize semesterArrayController, calendarArrayController, selectionArrayController, semselect ,calselect;
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
	NSUInteger max = 0;
	
	for (JONTUCourse *cse in [sem courses]) {
		for (JONTUClass *cls in [cse classes]) {
			if ([[cls activeWeeks] count] > max) {
				max = [[cls activeWeeks] count];
			}
		}
	}
	return max;
}

- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
	
    if ([date compare:endDate] == NSOrderedDescending) 
        return NO;
	
    return YES;
}

-(void)exportSemester:(JONTUSemester *)sem toCalendar:(CalCalendar *)cal usingDates:(NSDictionary *)dates {
	
	//******** course details stuff ***********//
	
	[progressDescription setStringValue:@"Retriving extra course information"];
	[progressProgressIndicator setMaxValue:[[sem courses] count]];
	[progressProgressIndicator setIndeterminate:NO];
	[progressProgressIndicator setDoubleValue:0.0];
	
	for (JONTUCourse *cse in [sem courses]) {
		[cse parse];
		[progressProgressIndicator incrementBy:1];
	}
	
	
	//******** calendar stuff ***********//
	
	// basic assumptions.
	// - school always starts on a monday.
	// - recess is for a week if not otherwise stated
	// - monday starts with index 0 since school always starts on a monday
	
	[[CalCalendarStore defaultCalendarStore] saveCalendar:cal error:nil];
	
	[progressDescription setStringValue:@"Begin export to iCal"];
	
	NSUInteger maxWeeks = [self maxWeeksForSemester:sem];
	[progressProgressIndicator setMaxValue:maxWeeks+1];
	[progressProgressIndicator setIndeterminate:NO];
	[progressProgressIndicator setDoubleValue:0.0];	
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDate *baseStartDate = [dates objectForKey:@"SEM_START"];
	
	NSDate *recessStartDate = [dates objectForKey:@"RECESS_START"];
	NSDate *recessEndDate = [dates objectForKey:@"RECESS_END"];

	if (!recessEndDate) {
		NSDateComponents *offset = [[NSDateComponents alloc] init];
		[offset setDay:5];
		recessEndDate = [calendar dateByAddingComponents:offset toDate:recessStartDate options:0];
		[offset release];
	}
	
	NSDateComponents *offset = nil;
	NSDate *currentWeekDate = nil;
	int modifier = 0;
	BOOL process = 0;

	for (int i=1;i<maxWeeks+2;i++) {
		offset = [[NSDateComponents alloc] init];
		[offset setDay:(i-1)*7];
		currentWeekDate = [calendar dateByAddingComponents:offset toDate:baseStartDate options:0];
		[progressProgressIndicator incrementBy:1];
		 
		if (![self date:currentWeekDate isBetweenDate:recessStartDate andDate:recessEndDate]) {
			[progressDescription setStringValue:[NSString stringWithFormat:@"Working on week %i",i-modifier]];
			for (JONTUCourse *cse in [sem courses]) {
				for (JONTUClass *cls in [cse classes]) {
					
					if ([[cls activeWeeks] count] < maxWeeks) {
						if (i-2 < [[cls activeWeeks] count]) {
							process = [cls isActiveForWeek:i-modifier];
						} else {
							process = NO;
						}
					} else {
						process = [cls isActiveForWeek:i-modifier];
					}
					
					if (process) {
						CalEvent *event = [CalEvent event];
						event.calendar = cal;
						event.title = [NSString stringWithFormat:@"%@: %@ %@", [cse name], [cse title], [cls type]];
						event.location = [cls venue];
						event.notes = [NSString stringWithFormat:@"%i AU %@ %@\nStatus: %@\n\nIndex: %@\nGroup: %@\nRemark: %@",[cse au], [cse type], [cse gepre], [cse status], [cse index], [cls group], [cls remark]];
						
						NSDateComponents *tmpoffset;
						
						tmpoffset = [cls fromTime];
						[tmpoffset setDay:[tmpoffset weekday]];
						[tmpoffset setWeekday:0];
						
						event.startDate = [calendar dateByAddingComponents:tmpoffset toDate:currentWeekDate options:0];

						tmpoffset = [cls toTime];
						[tmpoffset setDay:[tmpoffset weekday]];
						[tmpoffset setWeekday:0];

						event.endDate = [calendar dateByAddingComponents:tmpoffset toDate:currentWeekDate options:0];

						[[CalCalendarStore defaultCalendarStore] saveEvent:event span:CalSpanThisEvent error:nil];						
					}						
					
				}
			}
		} else {
			[progressDescription setStringValue:@"Working on Recess Week"];

			modifier++;
		}	
	
		[offset release], offset = nil;
	}
	[[CalCalendarStore defaultCalendarStore] saveCalendar:cal error:nil];
	[self dismissSheet:progressWindow sender:nil];	
	
}

-(IBAction)selectDates:(id)sender {
	[self dismissSheet:additionalOptionsWindow sender:sender];
	[NSApp beginSheet:progressWindow modalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[progressProgressIndicator startAnimation:sender];
	
	NSMutableDictionary *dates = [NSMutableDictionary dictionary];
	[dates setObject:firstDay forKey:@"SEM_START"];
	[dates setObject:recess forKey:@"RECESS_START"];
	CalCalendar *inputCal;
	
	if ([calselect indexOfSelectedItem] < 0) {
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
		
		if ([calselect indexOfSelectedItem] < 0) {
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
			alertstring = @"Current semester has no courses to be exported.";
		} else if (([semselect indexOfSelectedItem] < 0) && ([[calselect stringValue] isEqualToString:@""])) {
			alertstring = @"Please make sure you have selected a semester to export as well as a calendar or entered the name of a new calendar to create and export to.";
		} else if ([semselect indexOfSelectedItem] < 0) {
			alertstring = @"Please make sure you have selected a semester to export.";
		} else if ([[calselect stringValue] isEqualToString:@""]) {
			alertstring = @"Please make sure you have selected a calendar or entered the name of a new calendar to create and export to.";
		}
		
		
		NSAlert *aha = [NSAlert alertWithMessageText:@"Invalid options"
									   defaultButton:@"OK"
									 alternateButton:nil 
										 otherButton:nil 
						   informativeTextWithFormat:alertstring];

		[aha beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
	}
}

-(void)showFirstSelection:(id)sender {	
	[selectionArrayController setContent:nil];
	[selectionArrayController rearrangeObjects];
	[selectionArrayController setContent:[[[semesterArrayController selection] valueForKey:@"self"] courses]];
	[selectionArrayController rearrangeObjects];
}

-(IBAction)getSemesters:(id)sender {

	NSString *loginpasswd = [loginPassword stringValue];
	NSString *loginuser = [loginUser stringValue];
	[loginButton setEnabled:NO];
	[loginCancelButton setEnabled:NO];
	[loginUser setEnabled:NO];
	[loginPassword setEnabled:NO];

	[loginSpinner startAnimation:sender];
	[loginStatus setHidden:YES];
	
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	NSBlockOperation *blockop = [NSBlockOperation blockOperationWithBlock:^{

		NSArray *test = [[JONTUSemester listSemestersOfUser:loginuser password:loginpasswd domain:@"STUDENT" parseImmediately:YES] retain];

		if (test) {
			[self dismissSheet:loginWindow sender:sender];
						
			[semesterArrayController setContent:test];			
			[semesterArrayController rearrangeObjects];
			[semesterArrayController setSelectionIndex:0];

			[self performSelectorOnMainThread:@selector(showFirstSelection:) withObject:nil waitUntilDone:NO];
			
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
