#include <fcntl.h>
#include <unistd.h>
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>
#include <substrate.h>

__attribute__((constructor))
static void Amber18DiagnosticLoaded(void)
{
    const char *outputPath =
        "/var/mobile/Library/Caches/com.apple.cameracaptured/Amber18Diagnostic-loaded.txt";

    const char *h10Path =
        "/System/Library/MediaCapture/H10ISP.mediacapture";

    const char *symbolName =
        "__ZN6H10ISP12H10ISPDevice27SetIndividualTorchLEDLevelsEjj";

    char message[1024];

    void *handle = dlopen(h10Path, RTLD_NOW);

    if (handle == NULL) {
        const char *error = dlerror();

        snprintf(message, sizeof(message),
                 "constructor: YES\n"
                 "H10ISP dlopen: FAILED\n"
                 "dlerror: %s\n",
                 error ? error : "(no error text)");
    } else {
        MSImageRef image = MSGetImageByName(h10Path);
        void *symbol = image ? MSFindSymbol(image, symbolName) : NULL;

        snprintf(message, sizeof(message),
                 "constructor: YES\n"
                 "H10ISP dlopen: SUCCESS\n"
                 "MSGetImageByName: %s\n"
                 "MSFindSymbol SetIndividualTorchLEDLevels: %s\n",
                 image ? "FOUND" : "NOT FOUND",
                 symbol ? "FOUND" : "NOT FOUND");

        dlclose(handle);
    }

    int fd = open(outputPath, O_WRONLY | O_CREAT | O_TRUNC, 0644);

    if (fd >= 0) {
        write(fd, message, strlen(message));
        close(fd);
    }
}
