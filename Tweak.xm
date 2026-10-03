#include <fcntl.h>
#include <unistd.h>

__attribute__((constructor))
static void Amber18DiagnosticLoaded(void)
{
    const char *path =
        "/var/mobile/Library/Caches/com.apple.cameracaptured/Amber18Diagnostic-loaded.txt";

    const char message[] =
        "Amber18Diagnostic loaded into cameracaptured\n";

    int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0644);

    if (fd >= 0) {
        write(fd, message, sizeof(message) - 1);
        close(fd);
    }
}
