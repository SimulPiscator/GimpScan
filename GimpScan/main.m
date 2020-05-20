//
//  main.m
//  GimpScan
//
//  Copyright © 2020 Simul Piscator. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <libgimp/gimp.h>

int __argc;
const char** __argv;

static jmp_buf sRunEnv;
static bool sDoCatchExit = true;

static void query()
{
    static GimpParamDef params[] =
    {
        { GIMP_PDB_INT32, "run_mode", "Interactive, non-interactive" },
    };
    gimp_install_procedure (
      "gimpscan-macos",
      "Scanner data import",
      "Import image data from scanners on MacOS",
      "Simul Piscator",
      "Copyright Simul Piscator",
      "2020",
      "<Toolbox>/File/Acquire/Scanner...",
      "",
      GIMP_PLUGIN,
      sizeof(params) / sizeof(*params), 0,
      params, NULL);
}

static void catchExit()
{
    if(sDoCatchExit)
        longjmp(sRunEnv, 1);
}

static void run (const gchar      *name,
                 gint              nparams,
                 const GimpParam  *param,
                 gint             *nreturn_vals,
                 GimpParam       **return_vals)
{
    GimpRunMode run_mode = param[0].data.d_int32;
    if (run_mode == GIMP_RUN_INTERACTIVE) {
        // If another instance is running, bring it to front and exit.
        // Otherwise, run the GUI.
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSArray<NSRunningApplication*>* list;
        list = [NSRunningApplication runningApplicationsWithBundleIdentifier: mainBundle.bundleIdentifier];
        if (list.count > 0) {
            NSRunningApplication* app = list.firstObject;
            NSApplicationActivationOptions options = NSApplicationActivateIgnoringOtherApps | NSApplicationActivateAllWindows;
            [app activateWithOptions:options];
        }
        else {
            // NSApplicationMain will never return but terminate with exit()
            // or kill() its own process.
            // For shutdown via exit(), the Info.plist entry "Application can
            // be killed immediately when user is shutting down or logging
            // out" must be set to "NO".
            atexit(&catchExit);
            if(!setjmp(sRunEnv))
                NSApplicationMain(__argc, __argv);
            sDoCatchExit = false;
        }
    }
    static GimpParam return_val;
    return_val.type = GIMP_PDB_STATUS;
    return_val.data.d_status = GIMP_PDB_SUCCESS;
    *return_vals = &return_val;
    *nreturn_vals = 1;
}

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

static int install()
{
    NSString* appPath = @"/Applications/";
    NSString* pluginsPath = @"/Contents/Resources/lib/gimp/2.0/plug-ins/";
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* apps = [fileManager contentsOfDirectoryAtPath:appPath error:nil];
    NSMutableArray* matches = [NSMutableArray new];
    NSString* item;
    for (item in apps)
        if ([item rangeOfString:@"GIMP"].location == 0) {
            NSMutableString* gimpDir = [[NSMutableString alloc] initWithString:appPath];
            [gimpDir appendString:item];
            NSMutableString* pDir = [[NSMutableString alloc] initWithString:gimpDir];
            [pDir appendString:@"/"];
            [pDir appendString:pluginsPath];
            if ([fileManager fileExistsAtPath:pDir])
                [matches addObject:gimpDir];
        }
    if (matches.count == 0) {
        NSAlert* alert = [NSAlert new];
        alert.messageText = @"GimpScan needs to be installed into GIMP before it can be used, but no GIMP application was found.";
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        return 0;
    }
    NSMutableString* text = [[NSMutableString alloc] initWithString:@"GimpScan needs to be installed into GIMP before it can be used.\n\nThe following GIMP applications have been found:\n\n"];
    for (item in matches) {
        [text appendString:item];
        [text appendString:@"\n"];
    }
    [text appendString:@"\nProceed with installation?\n"];
    
    NSAlert* alert = [NSAlert new];
    alert.messageText = text;
    [alert addButtonWithTitle:@"Install"];
    [alert addButtonWithTitle:@"Don't Install"];
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
    
    for (item in matches) {
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
        [symlinkPath appendString:@"gimp-scan"];
        [fileManager createSymbolicLinkAtPath:symlinkPath withDestinationPath:pluginExePath error:&err];
        if (err)
            return errorExit(err);
    }
    return 0;
}

int main(int argc, const char* argv[])
{
    __argc = argc;
    __argv = argv;
    // When the executable path is a symlink, NSApplicationMain()
    // will not find the application bundle.
    // In that case, we restart execution with the
    // path resolved to the actual executable location.
    char buf[PATH_MAX];
    char* path = realpath(argv[0], buf);
    if (path && strcmp(argv[0], path)) {
        char* argv_[argc + 1];
        argv_[0] = path;
        for (int i = 1; i < argc; ++i)
            argv_[i] = (char*)argv[i];
        argv_[argc] = NULL;
        execv(path, argv_);
    }
    if (argc < 2 || strcmp(argv[1], "-gimp")) {
        return install();
    }
    GimpPlugInInfo PLUG_IN_INFO = {
        NULL,
        NULL,
        &query,
        &run
    };
    return gimp_main(&PLUG_IN_INFO, argc, (char**)argv);
}

