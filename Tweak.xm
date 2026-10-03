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
    unsigned int amberLevels = levels ? (levels >> 8) : levels;

    const char *path =
        "/var/mobile/Library/Caches/com.apple.cameracaptured/Amber18Diagnostic-hook.txt";

    int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0644);

    if (fd >= 0) {
        char buffer[256];

        int length = snprintf(
            buffer,
            sizeof(buffer),
            "original: 0x%08X\n"
            "amber: 0x%08X\n",
            levels,
            amberLevels
        );

        write(fd, buffer, length);
        close(fd);
    }

    return originalSetIndividualTorchLEDLevels(
        device,
        arg1,
        amberLevels
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
