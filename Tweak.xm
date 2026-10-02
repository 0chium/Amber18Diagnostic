#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <substrate.h>

static void WriteLog(NSString *message) {
    NSString *path = @"/var/mobile/Documents/Amber18Diagnostic.txt";
    NSString *line = [NSString stringWithFormat:@"%@\n", message];

    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];

    if (!handle) {
        [line writeToFile:path
               atomically:YES
                 encoding:NSUTF8StringEncoding
                    error:nil];
        return;
    }

    [handle seekToEndOfFile];
    [handle writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
}

%ctor {
    @autoreleasepool {
        WriteLog(@"=== Amber18Diagnostic loaded ===");

        const char *path =
            "/System/Library/MediaCapture/H10ISP.mediacapture";

        void *handle = dlopen(path, RTLD_NOW);

        if (!handle) {
            const char *error = dlerror();
            WriteLog([NSString stringWithFormat:
                @"dlopen FAILED: %s",
                error ? error : "unknown error"]);
            return;
        }

        WriteLog(@"dlopen SUCCESS");

        const char *symbol =
            "__ZN6H10ISP12H10ISPDevice27SetIndividualTorchLEDLevelsEjj";

        void *address = dlsym(handle, symbol);

        if (address) {
            WriteLog([NSString stringWithFormat:
                @"SetIndividualTorchLEDLevels FOUND at %p",
                address]);
        } else {
            const char *error = dlerror();
            WriteLog([NSString stringWithFormat:
                @"SetIndividualTorchLEDLevels NOT FOUND: %s",
                error ? error : "unknown error"]);
        }
    }
}
