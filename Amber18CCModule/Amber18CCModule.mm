#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <unistd.h>

#import <ControlCenterUIKit/CCUIToggleModule.h>

@interface Amber18CCModule : CCUIToggleModule
@end

static NSString * const Amber18LogPath =
    @"/var/mobile/Documents/Amber18-runtime.txt";

static void Amber18Log(NSString *format, ...)
{
    va_list args;
    va_start(args, format);

    NSString *message =
        [[NSString alloc] initWithFormat:format arguments:args];

    va_end(args);

    NSString *line = [NSString stringWithFormat:
        @"%@\n", message];

    NSData *data =
        [line dataUsingEncoding:NSUTF8StringEncoding];

    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:Amber18LogPath]) {
        [data writeToFile:Amber18LogPath atomically:YES];
        return;
    }

    NSFileHandle *handle =
        [NSFileHandle fileHandleForWritingAtPath:Amber18LogPath];

    if (handle == nil)
        return;

    [handle seekToEndOfFile];
    [handle writeData:data];
    [handle closeFile];
}

@implementation Amber18CCModule

- (instancetype)init
{
    self = [super init];

    if (self) {
        Amber18Log(
            @"INIT process=%@ pid=%d class=%@",
            [[NSProcessInfo processInfo] processName],
            getpid(),
            NSStringFromClass([self class])
        );
    }

    return self;
}

- (id)flashlightController
{
    Amber18Log(@"flashlightController ENTER");

    Class controllerClass =
        NSClassFromString(@"SBUIFlashlightController");

    Amber18Log(
        @"SBUIFlashlightController class=%@",
        controllerClass ?
            NSStringFromClass(controllerClass) :
            @"nil"
    );

    if (controllerClass == Nil)
        return nil;

    SEL sharedSelector =
        sel_registerName("sharedInstance");

    BOOL hasShared =
        [controllerClass respondsToSelector:sharedSelector];

    Amber18Log(
        @"sharedInstance selector=%@",
        hasShared ? @"YES" : @"NO"
    );

    if (!hasShared)
        return nil;

    id controller =
        ((id (*)(id, SEL))objc_msgSend)(
            (id)controllerClass,
            sharedSelector
        );

    Amber18Log(
        @"sharedInstance object=%@ objectClass=%@",
        controller ? @"NON-NIL" : @"nil",
        controller ?
            NSStringFromClass([controller class]) :
            @"nil"
    );

    return controller;
}

- (NSUInteger)flashlightLevel
{
    Amber18Log(@"flashlightLevel ENTER");

    id controller = [self flashlightController];

    if (controller == nil) {
        Amber18Log(@"flashlightLevel controller=nil");
        return 0;
    }

    SEL selector = sel_registerName("level");

    BOOL hasLevel =
        [controller respondsToSelector:selector];

    Amber18Log(
        @"level selector=%@",
        hasLevel ? @"YES" : @"NO"
    );

    if (!hasLevel)
        return 0;

    NSUInteger level =
        ((NSUInteger (*)(id, SEL))objc_msgSend)(
            controller,
            selector
        );

    Amber18Log(
        @"flashlightLevel value=%llu",
        (unsigned long long)level
    );

    return level;
}

- (BOOL)isSelected
{
    Amber18Log(@"isSelected ENTER");

    NSUInteger level = [self flashlightLevel];
    BOOL selected = level != 0;

    Amber18Log(
        @"isSelected RETURN=%@ level=%llu",
        selected ? @"YES" : @"NO",
        (unsigned long long)level
    );

    return selected;
}

- (void)setSelected:(BOOL)selected
{
    Amber18Log(
        @"setSelected ENTER selected=%@",
        selected ? @"YES" : @"NO"
    );

    id controller = [self flashlightController];

    if (controller == nil) {
        Amber18Log(@"setSelected controller=nil");
        return;
    }

    NSUInteger before = [self flashlightLevel];

    Amber18Log(
        @"level BEFORE=%llu",
        (unsigned long long)before
    );

    if (selected) {
        SEL selector =
            sel_registerName("turnFlashlightOnForReason:");

        BOOL responds =
            [controller respondsToSelector:selector];

        Amber18Log(
            @"turnFlashlightOnForReason selector=%@",
            responds ? @"YES" : @"NO"
        );

        if (responds) {
            Amber18Log(@"CALL ON");

            ((void (*)(id, SEL, id))objc_msgSend)(
                controller,
                selector,
                @"Control Center"
            );

            Amber18Log(@"CALL ON RETURNED");
        }
    }
    else {
        SEL selector =
            sel_registerName("turnFlashlightOffForReason:");

        BOOL responds =
            [controller respondsToSelector:selector];

        Amber18Log(
            @"turnFlashlightOffForReason selector=%@",
            responds ? @"YES" : @"NO"
        );

        if (responds) {
            Amber18Log(@"CALL OFF");

            ((void (*)(id, SEL, id))objc_msgSend)(
                controller,
                selector,
                @"Control Center"
            );

            Amber18Log(@"CALL OFF RETURNED");
        }
    }

    NSUInteger after = [self flashlightLevel];

    Amber18Log(
        @"level AFTER=%llu",
        (unsigned long long)after
    );

    Amber18Log(@"setSelected EXIT");
}

@end
