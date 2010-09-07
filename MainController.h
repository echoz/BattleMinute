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
	NSWindow *additionalOptionsWindow;
	
	NSTextField *progressDescription;
	NSProgressIndicator *progressProgressIndicator;
	
	NSTextField *loginUser;
	NSSecureTextField *loginPassword;
	NSTextField *loginDomain;
	NSTextField *loginStatus;	
	NSButton *loginButton;
	NSButton *loginCancelButton;
	NSProgressIndicator *loginSpinner;
	
	NSPopUpButton *semselect;
	NSComboBox *calselect;
	
	NSDatePicker *firstDay;
	NSDatePicker *recess;
	
	NSArrayController *semesterArrayController;
	NSArrayController *calendarArrayController;
	NSArrayController *selectionArrayController;
	NSArray *calenders;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *loginWindow;
@property (assign) IBOutlet NSWindow *progressWindow;
@property (assign) IBOutlet NSWindow *additionalOptionsWindow;

@property (assign) IBOutlet NSTextField *progressDescription;
@property (assign) IBOutlet NSProgressIndicator *progressProgressIndicator;

@property (assign) IBOutlet NSTextField *loginUser;
@property (assign) IBOutlet NSSecureTextField *loginPassword;
@property (assign) IBOutlet NSTextField *loginDomain;
@property (assign) IBOutlet NSTextField *loginStatus;
@property (assign) IBOutlet NSButton *loginButton;
@property (assign) IBOutlet NSButton *loginCancelButton;
@property (assign) IBOutlet NSProgressIndicator *loginSpinner;

@property (assign) IBOutlet NSPopUpButton *semselect;
@property (assign) IBOutlet NSComboBox *calselect;

@property (assign) IBOutlet NSDatePicker *firstDay;
@property (assign) IBOutlet NSDatePicker *recess;

@property (assign) IBOutlet NSArrayController *semesterArrayController;
@property (assign) IBOutlet NSArrayController *calendarArrayController;
@property (assign) IBOutlet NSArrayController *selectionArrayController;
-(IBAction)getSemesters:(id)sender;
-(IBAction)quit:(id)sender;
-(IBAction)closeAdditionalOptions:(id)sender;
-(IBAction)exportToiCal:(id)sender;
-(IBAction)selectDates:(id)sender;
-(void)dismissSheet:(NSWindow *)win sender:(id)sender;

-(void)showFirstSelection:(id)sender;
@end
