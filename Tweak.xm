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

static int callCount = 0;

static int hookedSetIndividualTorchLEDLevels(
    void *device,
    unsigned int arg1,
    unsigned int levels
)
{
    callCount++;

    const char *path =
        "/var/mobile/Library/Caches/com.apple.cameracaptured/Amber18Diagnostic-hook.txt";

    int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0644);

    if (fd >= 0) {
        char buffer[64];
        int length = snprintf(
            buffer,
            sizeof(buffer),
            "hook called: %d\n",
            callCount
        );

        write(fd, buffer, length);
        close(fd);
    }

    return originalSetIndividualTorchLEDLevels(device, arg1, levels);
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
