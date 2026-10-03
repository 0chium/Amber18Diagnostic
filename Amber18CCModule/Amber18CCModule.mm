#import <Foundation/Foundation.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <notify.h>

#import <ControlCenterUIKit/CCUIToggleModule.h>

#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

#define AMBER_STATE_NAME "com.ochium.amber18.enabled"

#define LOG_PATH \
"/var/mobile/Library/Caches/com.apple.cameracaptured/Amber18Notify.txt"

@interface Amber18CCModule : CCUIToggleModule
@end

@implementation Amber18CCModule

- (BOOL)isSelected
{
    int token = -1;
    uint64_t state = 0;

    uint32_t regResult =
        notify_register_check(AMBER_STATE_NAME, &token);

    if (regResult != NOTIFY_STATUS_OK)
        return NO;

    uint32_t getResult =
        notify_get_state(token, &state);

    notify_cancel(token);

    if (getResult != NOTIFY_STATUS_OK)
        return NO;

    return state == 1;
}

- (void)setSelected:(BOOL)selected
{
    int token = -1;
    uint64_t state = 0;

    uint32_t regResult =
        notify_register_check(AMBER_STATE_NAME, &token);

    uint32_t setResult = 999;
    uint32_t getResult = 999;

    if (regResult == NOTIFY_STATUS_OK) {
        setResult =
            notify_set_state(token, selected ? 1 : 0);

        getResult =
            notify_get_state(token, &state);
    }

    char buffer[512];

    int length = snprintf(
        buffer,
        sizeof(buffer),
        "selected: %d\n"
        "notify_register_check: %u\n"
        "notify_set_state: %u\n"
        "notify_get_state: %u\n"
        "state read back: %llu\n",
        selected ? 1 : 0,
        regResult,
        setResult,
        getResult,
        (unsigned long long)state
    );

    int fd = open(
        LOG_PATH,
        O_WRONLY | O_CREAT | O_TRUNC,
        0644
    );

    if (fd >= 0) {
        write(fd, buffer, length);
        close(fd);
    }

    if (regResult == NOTIFY_STATUS_OK)
        notify_cancel(token);
}

@end
