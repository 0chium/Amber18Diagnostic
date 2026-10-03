#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <fcntl.h>
#import <unistd.h>
#import <stdio.h>

__attribute__((constructor))
static void FindFlashlightButtonIMP(void)
{
    Class cls = objc_getClass("CCUIFlashlightModuleViewController");

    if (cls == Nil)
        return;

    SEL sel = sel_registerName("buttonTapped:forEvent:");
    Method method = class_getInstanceMethod(cls, sel);

    if (method == NULL)
        return;

    IMP imp = method_getImplementation(method);

    Dl_info info;
    if (dladdr((void *)imp, &info) == 0)
        return;

    char output[1024];

    snprintf(
        output,
        sizeof(output),
        "Class: CCUIFlashlightModuleViewController\n"
        "Method: buttonTapped:forEvent:\n"
        "IMP: %p\n"
        "Image base: %p\n"
        "Image: %s\n"
        "Offset from image base: 0x%llx\n",
        (void *)imp,
        info.dli_fbase,
        info.dli_fname ? info.dli_fname : "(null)",
        (unsigned long long)(
            (uintptr_t)imp - (uintptr_t)info.dli_fbase
        )
    );

    const char *path =
        "/var/mobile/Library/Preferences/Amber18FlashlightIMP.txt";

    int fd = open(
        path,
        O_WRONLY | O_CREAT | O_TRUNC,
        0644
    );

    if (fd < 0)
        return;

    write(fd, output, strlen(output));
    close(fd);
}
