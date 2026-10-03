#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>

#import <ControlCenterUIKit/CCUIToggleModule.h>

#include <fcntl.h>
#include <unistd.h>

#define AMBER_FLAG_PATH \
"/var/mobile/Library/Caches/com.ochium.amber18.enabled"

@interface Amber18CCModule : CCUIToggleModule
@end

@implementation Amber18CCModule

- (BOOL)isSelected
{
    return access(AMBER_FLAG_PATH, F_OK) == 0;
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        int fd = open(
            AMBER_FLAG_PATH,
            O_WRONLY | O_CREAT | O_TRUNC,
            0644
        );

        if (fd >= 0)
            close(fd);
    } else {
        unlink(AMBER_FLAG_PATH);
    }

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
