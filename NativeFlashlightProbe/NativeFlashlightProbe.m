#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
#import <dlfcn.h>

@interface SBUIFlashlightController : NSObject
+ (instancetype)sharedInstance;
- (void)turnFlashlightOnForReason:(NSString *)reason;
@end

typedef uint32_t (*Amber18NotifyPostFunction)(const char *name);

static const char *kAmber18ProbeNotification =
    "com.ochium.amber18diagnostic.probe";

__attribute__((constructor))
static void Amber18NativeFlashlightProbeLoaded(void)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        /*
         * v0.0.32 diagnostic
         *
         * Resolve notify_post dynamically so the dylib has no
         * direct _notify_post bind target.
         */

        Amber18NotifyPostFunction notifyPost =
            (Amber18NotifyPostFunction)dlsym(
                RTLD_DEFAULT,
                "notify_post"
            );

        if (notifyPost != NULL) {
            notifyPost(kAmber18ProbeNotification);
        }

        SBUIFlashlightController *flashlight =
            [SBUIFlashlightController sharedInstance];

        if (flashlight != nil) {
            [flashlight turnFlashlightOnForReason:@"Control Center"];
        }
    });
}
