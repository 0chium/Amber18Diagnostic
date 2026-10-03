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
    contentViewControllerForContext:(id)context;

- (UIViewController<CCUIContentModuleBackgroundViewController> *)
    backgroundViewControllerForContext:(id)context;

- (NSUInteger)supportedGridSizeClasses;
- (BOOL)expandsGridSizeClassesForAccessibility;
- (NSString *)moduleDescription;

@end

@interface CCUISliderButtonModuleViewController : UIViewController

- (BOOL)isSelected;
- (void)setSelected:(BOOL)selected;

@end


#pragma mark - Diagnostic view controller

@interface Amber18ModuleViewController :
    CCUISliderButtonModuleViewController
    <CCUIContentModuleContentViewController>
@end


@implementation Amber18ModuleViewController

- (instancetype)initWithNibName:(NSString *)nibName
                         bundle:(NSBundle *)bundle
{
    self = [super initWithNibName:nibName bundle:bundle];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    /*
     * DIAGNOSTIC STAGE 1
     *
     * If this controller is actually instantiated and viewDidLoad runs,
     * the Amber control should show a CHECKMARK.
     */

    UIImage *loadedImage =
        [UIImage systemImageNamed:@"checkmark.circle.fill"];

    SEL setGlyphSelector =
        NSSelectorFromString(@"setGlyphImage:");

    SEL setSelectedGlyphSelector =
        NSSelectorFromString(@"setSelectedGlyphImage:");

    if ([self respondsToSelector:setGlyphSelector]) {
        ((void (*)(id, SEL, id))objc_msgSend)(
            self,
            setGlyphSelector,
            loadedImage
        );
    }

    if ([self respondsToSelector:setSelectedGlyphSelector]) {
        ((void (*)(id, SEL, id))objc_msgSend)(
            self,
            setSelectedGlyphSelector,
            loadedImage
        );
    }

    [super setSelected:NO];
}

- (void)buttonTapped:(id)sender forEvent:(id)event
{
    /*
     * DIAGNOSTIC STAGE 2
     *
     * If iOS 18.2 routes a tap here, replace the checkmark with an X.
     */

    UIImage *tapImage =
        [UIImage systemImageNamed:@"xmark.circle.fill"];

    SEL setGlyphSelector =
        NSSelectorFromString(@"setGlyphImage:");

    SEL setSelectedGlyphSelector =
        NSSelectorFromString(@"setSelectedGlyphImage:");

    if ([self respondsToSelector:setGlyphSelector]) {
        ((void (*)(id, SEL, id))objc_msgSend)(
            self,
            setGlyphSelector,
            tapImage
        );
    }

    if ([self respondsToSelector:setSelectedGlyphSelector]) {
        ((void (*)(id, SEL, id))objc_msgSend)(
            self,
            setSelectedGlyphSelector,
            tapImage
        );
    }

    [super setSelected:YES];
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
