//
//  AppDelegate.m
//  GimpScan
//
//  Copyright © 2020 Simul Piscator. All rights reserved.
//

#import "AppDelegate.h"
#include <libgimp/gimp.h>

extern int __argc;
extern const char** __argv;

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (weak) IKScannerDeviceView* scanner;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSView* view = self.window.contentView;
    for (id subview in view.subviews) {
        if ([subview isKindOfClass:[IKScannerDeviceView class]]) {
            self.scanner = subview;
            self.scanner.delegate = self;
            break;
        }
    }
    self.scanner.documentName = @"Scan";
    self.scanner.postProcessApplication = nil;
    
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    // For this notification to be given, the Info.plist entry "Application
    // can be killed immediately when user is shutting down or logging out"
    // must be set to "NO".
    gimp_quit();
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)scannerDeviceView: (IKScannerDeviceView *)scannerDeviceView didScanToURL: (NSURL *)url fileData: (NSData *)data error: (NSError *)error {
    
    if (url) {
        const char* filename = url.fileSystemRepresentation;
        gint32 img = gimp_file_load(GIMP_RUN_NONINTERACTIVE, filename, filename);
        gimp_image_set_filename(img, "");
        gimp_display_new(img);
        unlink(filename);

        // Bring GIMP to front.
        pid_t gimpPid = gimp_getpid();
        NSRunningApplication* gimp = [NSRunningApplication runningApplicationWithProcessIdentifier:gimpPid];
        if (gimp) {
            NSApplicationActivationOptions options = NSApplicationActivateIgnoringOtherApps | NSApplicationActivateAllWindows;
            [gimp activateWithOptions:options];
        }
    }
}
@end
