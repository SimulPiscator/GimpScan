//
//  install.m
//  GimpScan
//
//  Copyright © 2020 Simul Piscator. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern int __argc;
extern const char** __argv;

static int errorExit(NSError* err)
{
    NSAlert* alert = [NSAlert new];
    if (err)
        alert.messageText = err.description;
    else
        alert.messageText = @"An unexpected error occurred.";
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
    return -1;
}

int install()
{
    NSString* appPath = @"/Applications/";
    NSString* pluginsPath = @"/Contents/Resources/lib/gimp/2.0/plug-ins/";
    NSString* symlinkName = @"gimp-scan";
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* apps = [fileManager contentsOfDirectoryAtPath:appPath error:nil];
    NSMutableArray* matchesWithout = [NSMutableArray new];
    NSMutableArray* matchesWith = [NSMutableArray new];
    NSString* item;
    for (item in apps) {
        if ([item rangeOfString:@"GIMP"].location == 0) {
            NSMutableString* gimpDir = [[NSMutableString alloc] initWithString:appPath];
            [gimpDir appendString:item];
            NSMutableString* pDir = [[NSMutableString alloc] initWithString:gimpDir];
            [pDir appendString:@"/"];
            [pDir appendString:pluginsPath];
            NSMutableString* pSymlink = [[NSMutableString alloc] initWithString:pDir];
            [pSymlink appendString:symlinkName];
            if ([fileManager fileExistsAtPath:pDir]) {
                if ([fileManager fileExistsAtPath:pSymlink])
                    [matchesWith addObject:gimpDir];
                else
                    [matchesWithout addObject:gimpDir];
            }
        }
    }
    if (matchesWithout.count > 0 && matchesWith.count > 0) {
        NSAlert* alert = [NSAlert new];
        alert.messageText = @"Multiple GIMP installations have been found, cannot automatically install or uninstall.";
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        return 0;
    }
    if (matchesWithout.count == 0 && matchesWith.count == 0) {
        NSAlert* alert = [NSAlert new];
        alert.messageText = @"GimpScan needs to be installed into GIMP before it can be used, but no GIMP application was found.";
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        return 0;
    }
    if (matchesWithout.count > 0) {
        NSMutableString* text = [[NSMutableString alloc] initWithString:@"GimpScan needs to be installed into GIMP before it can be used.\n\nThe following GIMP applications have been found:\n\n"];
        for (item in matchesWithout) {
            [text appendString:item];
            [text appendString:@"\n"];
        }
        [text appendString:@"\nProceed with installation?\n"];
        
        NSAlert* alert = [NSAlert new];
        alert.messageText = text;
        [alert addButtonWithTitle:@"Install"];
        [alert addButtonWithTitle:@"Don't Install"];
        [NSApp activateIgnoringOtherApps:YES];
        NSModalResponse response = [alert runModal];
        if (response != NSAlertFirstButtonReturn)
            return 0;
        
        NSError* err = nil;
        NSString* thisApp = [[NSBundle mainBundle] bundlePath];
        NSString* thisExe = [[NSString alloc] initWithCString:__argv[0] encoding:NSUTF8StringEncoding];
        NSRange range = [thisExe rangeOfString:thisApp];
        if (range.location != 0 || range.length != thisApp.length)
            return errorExit(nil);
        NSString* appToExe = [thisExe substringFromIndex:thisApp.length];
        NSURL* appUrl = [[NSURL alloc] initWithString:thisApp];
        NSString* appName = appUrl.lastPathComponent;
        
        for (item in matchesWithout) {
            NSMutableString* gimpPluginPath = [[NSMutableString alloc] initWithString:item];
            [gimpPluginPath appendString:pluginsPath];
            NSMutableString* copiedApp = [[NSMutableString alloc] initWithString:gimpPluginPath];
            [copiedApp appendString:appName];
            [fileManager copyItemAtPath:thisApp toPath:copiedApp error:&err];
            if (err)
                return errorExit(err);
            NSMutableString* pluginExePath = [[NSMutableString alloc] initWithString:appName];
            [pluginExePath appendString:appToExe];
            NSMutableString* symlinkPath = [[NSMutableString alloc] initWithString:gimpPluginPath];
            [symlinkPath appendString:symlinkName];
            [fileManager createSymbolicLinkAtPath:symlinkPath withDestinationPath:pluginExePath error:&err];
            if (err)
                return errorExit(err);
        }
        alert = [NSAlert new];
        alert.messageText = @"The GimpScan plugin was installed successfully.";
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else {
        NSMutableString* text = [[NSMutableString alloc] initWithString:@"GimpScan has been installed already.\n\nThe following GIMP applications with GimpScan have been found:\n\n"];
        for (item in matchesWith) {
            [text appendString:item];
            [text appendString:@"\n"];
        }
        [text appendString:@"\nDo you want to uninstall GimpScan?\n"];
            
        NSAlert* alert = [NSAlert new];
        alert.messageText = text;
        [alert addButtonWithTitle:@"Uninstall"];
        [alert addButtonWithTitle:@"Quit without Uninstalling"];
        [NSApp activateIgnoringOtherApps:YES];
        NSModalResponse response = [alert runModal];
        if (response != NSAlertFirstButtonReturn)
            return 0;
            
        NSError* err = nil;
        NSString* thisApp = [[NSBundle mainBundle] bundlePath];
        NSURL* appUrl = [[NSURL alloc] initWithString:thisApp];
        NSString* appName = appUrl.lastPathComponent;
            
        for (item in matchesWith) {
            NSMutableString* gimpPluginPath = [[NSMutableString alloc] initWithString:item];
            [gimpPluginPath appendString:pluginsPath];
            NSMutableString* copiedApp = [[NSMutableString alloc] initWithString:gimpPluginPath];
            [copiedApp appendString:appName];
            [fileManager removeItemAtPath:copiedApp error:&err];
            if (err)
                return errorExit(err);
            NSMutableString* symlinkPath = [[NSMutableString alloc] initWithString:gimpPluginPath];
            [symlinkPath appendString:symlinkName];
            [fileManager removeItemAtPath:symlinkPath error:&err];
            if (err)
                return errorExit(err);
        }
        alert = [NSAlert new];
        alert.messageText = @"The GimpScan plugin was removed successfully.";
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    return 0;
}
