#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/message.h>

#pragma mark - Private Control Center declarations

@protocol CCUIContentModuleContentViewController <NSObject>
@end

@protocol CCUIContentModuleBackgroundViewController <NSObject>
@end

@protocol CCUIContentModule <NSObject>

@required

@property (nonatomic, readonly)
    UIViewController<CCUIContentModuleContentViewController>
        *contentViewController;

@property (nonatomic, readonly)
    UIViewController<CCUIContentModuleBackgroundViewController>
        *backgroundViewController;

@optional

- (UIViewController<CCUIContentModuleContentViewController> *)
    contentViewController;

- (UIViewController<CCUIContentModuleContentViewController> *)
    contentViewControllerForContext:(id)context;

- (BOOL)expandsGridSizeClassesForAccessibility;
- (NSUInteger)supportedGridSizeClasses;
- (void)setContentModuleContext:(id)context;

- (UIViewController<CCUIContentModuleBackgroundViewController> *)
    backgroundViewControllerForContext:(id)context;

- (UIViewController<CCUIContentModuleBackgroundViewController> *)
    backgroundViewController;

- (NSString *)moduleDescription;

@end


@interface CCUISliderButtonModuleViewController : UIViewController

- (BOOL)isSelected;
- (void)setSelected:(BOOL)selected;

@end


#pragma mark - Private SpringBoardUI declarations

@protocol SBUIFlashlightObserver <NSObject>

@required

- (void)flashlightLevelDidChange:(id)notification;
- (void)flashlightAvailabilityDidChange:(id)notification;

@optional

- (void)flashlightOverheatedDidChange:(id)notification;

@end


@interface SBUIFlashlightController : NSObject

+ (instancetype)sharedInstance;

- (NSUInteger)level;
- (BOOL)isAvailable;

- (void)addObserver:(id<SBUIFlashlightObserver>)observer;
- (void)removeObserver:(id<SBUIFlashlightObserver>)observer;

- (void)turnFlashlightOnForReason:(NSString *)reason;
- (void)turnFlashlightOffForReason:(NSString *)reason;

@end


#pragma mark - Amber view controller

@interface Amber18ModuleViewController :
    CCUISliderButtonModuleViewController
    <CCUIContentModuleContentViewController,
     SBUIFlashlightObserver>
{
    SBUIFlashlightController *_flashlight;
}

@end


@implementation Amber18ModuleViewController

- (instancetype)initWithNibName:(NSString *)nibName
                         bundle:(NSBundle *)bundle
{
    self = [super initWithNibName:nibName bundle:bundle];

    if (self) {
        _flashlight = [SBUIFlashlightController sharedInstance];

        if (_flashlight != nil) {
            [_flashlight addObserver:self];
        }
    }

    return self;
}

- (void)dealloc
{
    if (_flashlight != nil) {
        [_flashlight removeObserver:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *offImage =
        [UIImage systemImageNamed:@"flashlight.off.fill"];

    UIImage *onImage =
        [UIImage systemImageNamed:@"flashlight.on.fill"];

    SEL setGlyphSelector =
        NSSelectorFromString(@"setGlyphImage:");

    SEL setSelectedGlyphSelector =
        NSSelectorFromString(@"setSelectedGlyphImage:");

    if ([self respondsToSelector:setGlyphSelector]) {
        ((void (*)(id, SEL, id))objc_msgSend)(
            self,
            setGlyphSelector,
            offImage
        );
    }

    if ([self respondsToSelector:setSelectedGlyphSelector]) {
        ((void (*)(id, SEL, id))objc_msgSend)(
            self,
            setSelectedGlyphSelector,
            onImage
        );
    }

    [self amber18UpdateState];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self amber18UpdateState];
}

- (void)amber18UpdateState
{
    if (_flashlight == nil)
        return;

    BOOL on = [_flashlight level] != 0;
    [super setSelected:on];
}

- (void)buttonTapped:(id)sender
            forEvent:(id)event
{
    if (_flashlight == nil)
        return;

    BOOL currentlyOn =
        [_flashlight level] != 0;

    if (currentlyOn) {
        [super setSelected:NO];

        [_flashlight
            turnFlashlightOffForReason:@"Control Center"];
    }
    else {
        [super setSelected:YES];

        [_flashlight
            turnFlashlightOnForReason:@"Control Center"];
    }
}


#pragma mark - SBUIFlashlightObserver

- (void)flashlightLevelDidChange:(id)notification
{
    [self amber18UpdateState];
}

- (void)flashlightAvailabilityDidChange:(id)notification
{
    [self amber18UpdateState];
}

- (void)flashlightOverheatedDidChange:(id)notification
{
    [self amber18UpdateState];
}

@end


#pragma mark - Amber content module

@interface Amber18CCModule :
    NSObject <CCUIContentModule>
{
    Amber18ModuleViewController *_viewController;
}

@end


@implementation Amber18CCModule

- (UIViewController<CCUIContentModuleContentViewController> *)
    contentViewController
{
    return _viewController;
}

- (UIViewController<CCUIContentModuleContentViewController> *)
    contentViewControllerForContext:(id)context
{
    if (_viewController == nil) {
        NSBundle *bundle =
            [NSBundle bundleForClass:[self class]];

        _viewController =
            [[Amber18ModuleViewController alloc]
                initWithNibName:nil
                        bundle:bundle];
    }

    return _viewController;
}

- (UIViewController<CCUIContentModuleBackgroundViewController> *)
    backgroundViewController
{
    return nil;
}

- (UIViewController<CCUIContentModuleBackgroundViewController> *)
    backgroundViewControllerForContext:(id)context
{
    return nil;
}

- (NSUInteger)supportedGridSizeClasses
{
    return 1;
}

- (BOOL)expandsGridSizeClassesForAccessibility
{
    return NO;
}

- (NSString *)moduleDescription
{
    return @"Amber";
}

@end
