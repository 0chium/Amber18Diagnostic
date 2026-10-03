#include <dlfcn.h>
#include <substrate.h>

static int (*originalSetIndividualTorchLEDLevels)(
    void *,
    unsigned int,
    unsigned int
);

static int hookedSetIndividualTorchLEDLevels(
    void *device,
    unsigned int arg1,
    unsigned int levels
)
{
    unsigned int finalLevels = levels;

    if (levels != 0)
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
