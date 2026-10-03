#include <dlfcn.h>
#include <substrate.h>
#include <notify.h>

#define AMBER_STATE_NAME "com.ochium.amber18.enabled"

static int amberNotifyToken = -1;

static int (*originalSetIndividualTorchLEDLevels)(
    void *,
    unsigned int,
    unsigned int
);

static bool AmberEnabled(void)
{
    if (amberNotifyToken < 0)
        return false;

    uint64_t state = 0;

    if (notify_get_state(amberNotifyToken, &state) != NOTIFY_STATUS_OK)
        return false;

    return state == 1;
}

static int hookedSetIndividualTorchLEDLevels(
    void *device,
    unsigned int arg1,
    unsigned int levels
)
{
    unsigned int finalLevels = levels;

    if (levels != 0 && AmberEnabled())
        finalLevels = levels >> 8;

    return originalSetIndividualTorchLEDLevels(
        device,
        arg1,
        finalLevels
    );
}

__attribute__((constructor))
static void Amber18Loaded(void)
{
    if (notify_register_check(
            AMBER_STATE_NAME,
            &amberNotifyToken
        ) != NOTIFY_STATUS_OK) {
        amberNotifyToken = -1;
    }

    const char *h10Path =
        "/System/Library/MediaCapture/H10ISP.mediacapture";

    const char *symbolName =
        "__ZN6H10ISP12H10ISPDevice27SetIndividualTorchLEDLevelsEjj";

    if (dlopen(h10Path, RTLD_NOW) == NULL)
        return;

    MSImageRef image = MSGetImageByName(h10Path);

    if (image == NULL)
        return;

    void *symbol = MSFindSymbol(image, symbolName);

    if (symbol == NULL)
        return;

    MSHookFunction(
        symbol,
        (void *)&hookedSetIndividualTorchLEDLevels,
        (void **)&originalSetIndividualTorchLEDLevels
    );
}
