#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <notify.h>

#import <ControlCenterUIKit/CCUIToggleModule.h>

#define AMBER_STATE_NAME "com.ochium.amber18.enabled"

@interface Amber18CCModule : CCUIToggleModule
@end

@implementation Amber18CCModule

- (BOOL)isSelected
{
    int token = -1;
    uint64_t state = 0;

    if (notify_register_check(AMBER_STATE_NAME, &token)
        != NOTIFY_STATUS_OK) {
        return NO;
    }

    notify_get_state(token, &state);
    notify_cancel(token);

    return state == 1;
}

- (void)setSelected:(BOOL)selected
{
    int token = -1;

    if (notify_register_check(AMBER_STATE_NAME, &token)
        != NOTIFY_STATUS_OK) {
        return;
    }

    notify_set_state(token, selected ? 1 : 0);
    notify_post(AMBER_STATE_NAME);
    notify_cancel(token);

    Class controllerClass =
        objc_getClass("SBUIFlashlightController");

    if (controllerClass == Nil)
        return;

    id controller =
        ((id (*)(id, SEL))objc_msgSend)(
            (id)controllerClass,
            sel_registerName("sharedInstance")
        );

    if (controller == nil)
        return;

    if (selected) {
        SEL powerOnSEL = sel_registerName("_turnPowerOn");

        if ([controller respondsToSelector:powerOnSEL]) {
            ((void (*)(id, SEL))objc_msgSend)(
                controller,
                powerOnSEL
            );
        }
    } else {
        SEL powerOffSEL = sel_registerName("_turnPowerOff");

        if ([controller respondsToSelector:powerOffSEL]) {
            ((void (*)(id, SEL))objc_msgSend)(
                controller,
                powerOffSEL
            );
        }
    }
}

@end
