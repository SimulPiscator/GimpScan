//
//  main.m
//  GimpImageCapture
//
//  Created by Jürgen Mellinger on 09.05.20.
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
    GimpPlugInInfo PLUG_IN_INFO = {
        NULL,
        NULL,
        &query,
        &run
    };
    return gimp_main(&PLUG_IN_INFO, argc, (char**)argv);
}

