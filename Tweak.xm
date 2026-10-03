#import <Foundation/Foundation.h>

%ctor {
    @autoreleasepool {
        NSString *path = @"/var/mobile/tmp/Amber18Diagnostic-loaded.txt";
        NSString *message = @"Amber18Diagnostic loaded into cameracaptured\n";

        [message writeToFile:path
                  atomically:YES
                    encoding:NSUTF8StringEncoding
                       error:nil];
    }
}
