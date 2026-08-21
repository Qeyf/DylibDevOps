#import <Foundation/Foundation.h>

// Authorized regression PoC for the supplied PinterestPatch.dylib build.
// Scope is intentionally narrow: it only exercises the recovered
// `__sys_ui_shown` preference gate hypothesis.

static NSString * const DylibDevOpsGateKey = @"__sys_ui_shown";

__attribute__((visibility("default")))
BOOL DylibDevOpsApplyPremiumGateBypass(void) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:DylibDevOpsGateKey];
    return [defaults boolForKey:DylibDevOpsGateKey];
}

__attribute__((visibility("default")))
BOOL DylibDevOpsRemovePremiumGateBypass(void) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:DylibDevOpsGateKey];
    return [defaults objectForKey:DylibDevOpsGateKey] == nil;
}

__attribute__((constructor))
static void DylibDevOpsBypassInit(void) {
    @autoreleasepool {
        BOOL applied = DylibDevOpsApplyPremiumGateBypass();
        NSLog(@"[DylibDevOps] authorized PoC: %@=%d", DylibDevOpsGateKey, applied);
    }
}
