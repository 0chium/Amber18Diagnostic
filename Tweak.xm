#include <dlfcn.h>
#include <notify.h>
#include <substrate.h>

static const char *kAmber18ModeNotification =
    "com.ochium.amber18diagnostic.warm-mode";

static int gAmber18ModeToken = -1;

static int (*originalSetIndividualTorchLEDLevels)(
    void *,
    unsigned int,
    unsigned int
);

static bool Amber18WarmModeEnabled(void)
{
    uint64_t state = 0;

    if (gAmber18ModeToken < 0)
        return false;

    if (notify_get_state(gAmber18ModeToken, &state) != NOTIFY_STATUS_OK)
        return false;

    return state != 0;
}

static void Amber18ClearWarmMode(void)
{
    if (gAmber18ModeToken < 0)
        return;

    notify_set_state(gAmber18ModeToken, 0);
    notify_post(kAmber18ModeNotification);
}

static int hookedSetIndividualTorchLEDLevels(
    void *device,
    unsigned int arg1,
    unsigned int levels
)
{
    unsigned int finalLevels = levels;

    if (levels == 0) {
        Amber18ClearWarmMode();
    }
    else if (Amber18WarmModeEnabled()) {
        finalLevels = levels >> 8;
    }

    return originalSetIndividualTorchLEDLevels(
        device,
        arg1,
        finalLevels
    );
}

__attribute__((constructor))
static void Amber18Loaded(void)
{
    const char *h10Path =
        "/System/Library/MediaCapture/H10ISP.mediacapture";

    const char *symbolName =
        "__ZN6H10ISP12H10ISPDevice27SetIndividualTorchLEDLevelsEjj";

    if (notify_register_check(
            kAmber18ModeNotification,
            &gAmber18ModeToken
        ) != NOTIFY_STATUS_OK) {
        gAmber18ModeToken = -1;
    }

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
