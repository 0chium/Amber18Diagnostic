#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>

#import <ControlCenterUIKit/CCUIToggleModule.h>

@interface Amber18CCModule : CCUIToggleModule
@end

@implementation Amber18CCModule

- (id)flashlightController
{
    Class controllerClass =
        NSClassFromString(@"SBUIFlashlightController");

    if (controllerClass == Nil)
        return nil;

    SEL sharedSelector =
        sel_registerName("sharedInstance");

    if (![controllerClass respondsToSelector:sharedSelector])
        return nil;

    return ((id (*)(id, SEL))objc_msgSend)(
        (id)controllerClass,
        sharedSelector
    );
}

- (NSUInteger)flashlightLevel
{
    id controller = [self flashlightController];

    if (controller == nil)
        return 0;

    SEL selector = sel_registerName("level");

    if (![controller respondsToSelector:selector])
        return 0;

    return ((NSUInteger (*)(id, SEL))objc_msgSend)(
        controller,
        selector
    );
}

- (BOOL)isSelected
{
    return [self flashlightLevel] != 0;
}

- (void)setSelected:(BOOL)selected
{
    id controller = [self flashlightController];

    if (controller == nil)
        return;

    if (selected) {
        SEL selector =
            sel_registerName("turnFlashlightOnForReason:");

        if ([controller respondsToSelector:selector]) {
            ((void (*)(id, SEL, id))objc_msgSend)(
                controller,
                selector,
                @"Control Center"
            );
        }
    }
    else {
        SEL selector =
            sel_registerName("turnFlashlightOffForReason:");

        if ([controller respondsToSelector:selector]) {
            ((void (*)(id, SEL, id))objc_msgSend)(
                controller,
                selector,
                @"Control Center"
            );
        }
    }
}

@end
