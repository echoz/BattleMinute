//
//  BattleMinuteAppDelegate.m
//  BattleMinute
//
//  Created by Jeremy Foo on 8/7/10.
//  Copyright 2010 ORNYX. All rights reserved.
//

#import "BattleMinuteAppDelegate.h"

@implementation BattleMinuteAppDelegate

@synthesize window, loginWindow, sparkle;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	[sparkle setSendsSystemProfile:YES];
	[sparkle setAutomaticallyChecksForUpdates:YES];
}

-(NSString *)installationId {
    NSString *uuid = [[NSUserDefaults standardUserDefaults] valueForKey:@"uuid"];
    if (uuid == nil) {
        uuid_t buffer;
        char str[37];
        uuid_generate(buffer);
        uuid_unparse_upper(buffer, str);        
        uuid = [NSString stringWithFormat:@"%s", str];
        NSLog(@"Generated UUID %@", uuid);        
        [[NSUserDefaults standardUserDefaults] setValue:uuid forKey:@"uuid"];
    }
    return uuid;
}

- (NSArray *)feedParametersForUpdater:(SUUpdater *)updater sendingSystemProfile:(BOOL)sendingProfile {
    NSArray *keys = [NSArray arrayWithObjects:@"key", @"value", nil];
    NSArray *parameters = [NSArray arrayWithObjects:
						   [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:@"uuid",[self installationId],nil] forKeys:keys], nil
						   ];
    return parameters;
}

@end
