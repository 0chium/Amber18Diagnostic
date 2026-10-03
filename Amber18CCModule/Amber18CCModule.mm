#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>

#import <ControlCenterUIKit/CCUIToggleModule.h>

@interface Amber18CCModule : CCUIToggleModule
@end

@implementation Amber18CCModule

- (BOOL)isSelected
{
    Class controllerClass =
        objc_getClass("SBUIFlashlightController");

    if (controllerClass == Nil)
        return NO;

    id controller =
        ((id (*)(id, SEL))objc_msgSend)(
            (id)controllerClass,
            sel_registerName("sharedInstance")
        );

    if (controller == nil)
        return NO;

    SEL levelSEL = sel_registerName("level");

    if (![controller respondsToSelector:levelSEL])
        return NO;

    NSUInteger level =
        ((NSUInteger (*)(id, SEL))objc_msgSend)(
            controller,
            levelSEL
        );

    return level != 0;
}

- (void)setSelected:(BOOL)selected
{
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

    NSString *reason = @"Control Center";

    if (selected) {
        SEL selector =
            sel_registerName("turnFlashlightOnForReason:");

        if ([controller respondsToSelector:selector]) {
            ((void (*)(id, SEL, id))objc_msgSend)(
                controller,
                selector,
                reason
            );
        }
    } else {
        SEL selector =
            sel_registerName("turnFlashlightOffForReason:");

        if ([controller respondsToSelector:selector]) {
            ((void (*)(id, SEL, id))objc_msgSend)(
                controller,
                selector,
                reason
            );
        }
    }
}

@end
