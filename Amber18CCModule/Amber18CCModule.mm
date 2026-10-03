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

@implementation Amber18CCModule {
    id _appleFlashlightModule;
    id _appleFlashlightViewController;
}

- (id)appleFlashlightViewController
{
    if (_appleFlashlightViewController != nil)
        return _appleFlashlightViewController;

    NSBundle *bundle = [NSBundle bundleWithPath:
        @"/System/Library/ControlCenter/Bundles/FlashlightModule.bundle"];

    if (bundle == nil)
        return nil;

    [bundle load];

    Class moduleClass =
        NSClassFromString(@"CCUIFlashlightModule");

    if (moduleClass == Nil)
        return nil;

    _appleFlashlightModule =
        [[moduleClass alloc] init];

    if (_appleFlashlightModule == nil)
        return nil;

    SEL contentSelector =
        sel_registerName("contentViewController");

    if (![_appleFlashlightModule respondsToSelector:contentSelector])
        return nil;

    _appleFlashlightViewController =
        ((id (*)(id, SEL))objc_msgSend)(
            _appleFlashlightModule,
            contentSelector
        );

    return _appleFlashlightViewController;
}

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
    return Amber18WarmModeEnabled() &&
           [self flashlightLevel] != 0;
}

- (void)setSelected:(BOOL)selected
{
    id controller =
        [self appleFlashlightViewController];

    if (controller == nil)
        return;

    SEL buttonSelector =
        sel_registerName("buttonTapped:forEvent:");

    if (![controller respondsToSelector:buttonSelector])
        return;

    if (selected) {
        /*
         * Publish Warm mode before using the known-working
         * Apple Control Center flashlight activation path.
         */
        Amber18SetWarmMode(YES);

        ((void (*)(id, SEL, id, id))objc_msgSend)(
            controller,
            buttonSelector,
            nil,
            nil
        );
    }
    else {
        /*
         * Clear Warm mode before Apple's normal OFF request.
         */
        Amber18SetWarmMode(NO);

        if ([self flashlightLevel] != 0) {
            ((void (*)(id, SEL, id, id))objc_msgSend)(
                controller,
                buttonSelector,
                nil,
                nil
            );
        }
    }
}

@end
