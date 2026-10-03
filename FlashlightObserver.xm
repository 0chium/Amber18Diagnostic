#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <fcntl.h>
#import <unistd.h>
#import <string.h>
#import <stdio.h>

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
    if (imp == NULL)
        return;

    Dl_info info;
    memset(&info, 0, sizeof(info));

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

    NSString *result =
        [NSString stringWithUTF8String:output];

    if (result == nil)
        return;

    [result writeToFile:@"/var/mobile/Amber18FlashlightIMP.txt"
             atomically:YES
               encoding:NSUTF8StringEncoding
                  error:nil];
}

%hook CCUIFlashlightModuleViewController

- (void)viewDidLoad
{
    %orig;

    FindFlashlightButtonIMP();
}

%end
