#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <notify.h>

#import <ControlCenterUIKit/CCUIToggleModule.h>

static const char *kAmber18ModeNotification =
    "com.ochium.amber18diagnostic.warm-mode";

static int Amber18ModeToken(void)
{
    static int token = -1;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        int newToken = -1;

        if (notify_register_check(
                kAmber18ModeNotification,
                &newToken
            ) == NOTIFY_STATUS_OK) {
            token = newToken;
        }
    });

    return token;
}

static BOOL Amber18WarmModeEnabled(void)
{
    int token = Amber18ModeToken();
    uint64_t state = 0;

    if (token < 0)
        return NO;

    if (notify_get_state(token, &state) != NOTIFY_STATUS_OK)
        return NO;

    return state != 0;
}

static void Amber18SetWarmMode(BOOL enabled)
{
    int token = Amber18ModeToken();

    if (token < 0)
        return;

    notify_set_state(token, enabled ? 1 : 0);
    notify_post(kAmber18ModeNotification);
}

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

- (NSUInteger)flashlightLevelForController:(id)controller
{
    if (controller == nil)
        return 0;

    SEL levelSelector =
        sel_registerName("level");

    if (![controller respondsToSelector:levelSelector])
        return 0;

    return ((NSUInteger (*)(id, SEL))objc_msgSend)(
        controller,
        levelSelector
    );
}

- (BOOL)isSelected
{
    id controller = [self flashlightController];

    return Amber18WarmModeEnabled() &&
           [self flashlightLevelForController:controller] != 0;
}

- (void)setSelected:(BOOL)selected
{
    id controller = [self flashlightController];

    if (controller == nil)
        return;

    NSUInteger level =
        [self flashlightLevelForController:controller];

    if (selected) {
        Amber18SetWarmMode(YES);

        if (level == 0) {
            SEL onSelector =
                sel_registerName("turnFlashlightOnForReason:");

            if ([controller respondsToSelector:onSelector]) {
                ((void (*)(id, SEL, id))objc_msgSend)(
                    controller,
                    onSelector,
                    @"Amber18 Warm"
                );
            }
        }
        else {
            SEL setLevelSelector =
                sel_registerName("setLevel:");

            if ([controller respondsToSelector:setLevelSelector]) {
                ((void (*)(id, SEL, NSUInteger))objc_msgSend)(
                    controller,
                    setLevelSelector,
                    level
                );
            }
        }

        return;
    }

    Amber18SetWarmMode(NO);

    if (level != 0) {
        SEL offSelector =
            sel_registerName("turnFlashlightOffForReason:");

        if ([controller respondsToSelector:offSelector]) {
            ((void (*)(id, SEL, id))objc_msgSend)(
                controller,
                offSelector,
                @"Amber18 Warm"
            );
        }
    }
}

@end
