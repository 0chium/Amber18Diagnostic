#include <fcntl.h>
#include <unistd.h>
#include <dlfcn.h>
#include <stdio.h>
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
    // For now, amber mode is OFF.
    // Pass Apple's original LED levels through unchanged.
    unsigned int finalLevels = levels;

    return originalSetIndividualTorchLEDLevels(
        device,
        arg1,
        finalLevels
    );
}

__attribute__((constructor))
static void Amber18DiagnosticLoaded(void)
{
    const char *h10Path =
        "/System/Library/MediaCapture/H10ISP.mediacapture";

    const char *symbolName =
        "__ZN6H10ISP12H10ISPDevice27SetIndividualTorchLEDLevelsEjj";

    void *handle = dlopen(h10Path, RTLD_NOW);

    if (handle == NULL)
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
