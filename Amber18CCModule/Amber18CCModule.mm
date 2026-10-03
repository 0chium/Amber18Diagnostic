#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>

#import <ControlCenterUIKit/CCUIToggleModule.h>

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

- (BOOL)isSelected
{
    Class controllerClass =
        NSClassFromString(@"SBUIFlashlightController");

    if (controllerClass == Nil)
        return NO;

    SEL sharedSelector =
        sel_registerName("sharedInstance");

    if (![controllerClass respondsToSelector:sharedSelector])
        return NO;

    id controller =
        ((id (*)(id, SEL))objc_msgSend)(
            (id)controllerClass,
            sharedSelector
        );

    if (controller == nil)
        return NO;

    SEL levelSelector =
        sel_registerName("level");

    if (![controller respondsToSelector:levelSelector])
        return NO;

    NSUInteger level =
        ((NSUInteger (*)(id, SEL))objc_msgSend)(
            controller,
            levelSelector
        );

    return level != 0;
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

    ((void (*)(id, SEL, id, id))objc_msgSend)(
        controller,
        buttonSelector,
        nil,
        nil
    );
}

@end
