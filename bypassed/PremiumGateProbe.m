#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <os/log.h>

static NSString * const BCProbeKey = @"__sys_ui_shown";
static IMP BCOriginalObjectForKey = NULL;

static id BCProbeObjectForKey(id self, SEL _cmd, NSString *defaultName) {
    id (*original)(id, SEL, NSString *) = (void *)BCOriginalObjectForKey;
    id value = original(self, _cmd, defaultName);

    if ([defaultName isEqualToString:BCProbeKey]) {
        BOOL boolValue = [value respondsToSelector:@selector(boolValue)] ? [value boolValue] : NO;
        os_log_with_type(OS_LOG_DEFAULT,
                         OS_LOG_TYPE_DEFAULT,
                         "[PremiumGateProbe] observed key=%{public}@ value=%{public}@ bool=%{public}d bundle=%{public}@",
                         defaultName,
                         [value description],
                         boolValue,
                         [[NSBundle mainBundle] bundleIdentifier]);

        NSArray<NSString *> *symbols = [NSThread callStackSymbols];
        os_log_with_type(OS_LOG_DEFAULT,
                         OS_LOG_TYPE_DEFAULT,
                         "[PremiumGateProbe] call stack: %{public}@",
                         [symbols componentsJoinedByString:@"\n"]);
    }

    return value;
}

__attribute__((constructor))
static void BCInstallPremiumGateProbe(void) {
    @autoreleasepool {
        Class defaultsClass = [NSUserDefaults class];
        Method method = class_getInstanceMethod(defaultsClass, @selector(objectForKey:));
        if (method == NULL) {
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR,
                             "[PremiumGateProbe] NSUserDefaults objectForKey: not found");
            return;
        }

        BCOriginalObjectForKey = method_getImplementation(method);
        method_setImplementation(method, (IMP)BCProbeObjectForKey);

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id current = BCOriginalObjectForKey
            ? ((id (*)(id, SEL, NSString *))BCOriginalObjectForKey)(defaults, @selector(objectForKey:), BCProbeKey)
            : nil;

        BOOL boolValue = [current respondsToSelector:@selector(boolValue)] ? [current boolValue] : NO;
        os_log_with_type(OS_LOG_DEFAULT,
                         OS_LOG_TYPE_DEFAULT,
                         "[PremiumGateProbe] installed; current %{public}@=%{public}@ (%{public}d). Probe is read-only and never modifies defaults/entitlements.",
                         BCProbeKey,
                         [current description],
                         boolValue);
    }
}
