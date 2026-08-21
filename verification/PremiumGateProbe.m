#import <Foundation/Foundation.h>

// Diagnostic-only probe. It deliberately does not mutate NSUserDefaults,
// hook Objective-C methods, patch executable code, or unlock paid features.

__attribute__((visibility("default")))
BOOL DylibDevOpsObservedSystemUIShown(void) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"__sys_ui_shown"];
}

__attribute__((visibility("default")))
BOOL DylibDevOpsPredictedGateValue(void) {
    return !DylibDevOpsObservedSystemUIShown();
}

__attribute__((visibility("default")))
NSString *DylibDevOpsGateKey(void) {
    return @"__sys_ui_shown";
}

__attribute__((constructor))
static void DylibDevOpsProbeInit(void) {
    @autoreleasepool {
        BOOL observed = DylibDevOpsObservedSystemUIShown();
        BOOL predicted = DylibDevOpsPredictedGateValue();
        NSLog(@"[DylibDevOps] diagnostic only: key=%@ observed=%d predictedGate=%d",
              DylibDevOpsGateKey(), observed, predicted);
    }
}
