#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
#import <notify.h>

static const char *kAmber18ModeNotification =
    "com.ochium.amber18diagnostic.warm-mode";

@interface SBUIFlashlightController : NSObject
+ (instancetype)sharedInstance;
- (void)turnFlashlightOnForReason:(NSString *)reason;
@end

__attribute__((constructor))
static void Amber18NativeFlashlightProbeLoaded(void)
{
    int token = -1;

    if (notify_register_check(
            kAmber18ModeNotification,
            &token
        ) == NOTIFY_STATUS_OK) {

        notify_set_state(token, 1);
        notify_post(kAmber18ModeNotification);
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        SBUIFlashlightController *flashlight =
            [SBUIFlashlightController sharedInstance];

        if (flashlight != nil) {
            [flashlight
                turnFlashlightOnForReason:@"Control Center"];
        }
    });
}
