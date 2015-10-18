
/*
 * Simulate TapGuesture, by inject to get UITapGestureRecognizer callback
 *
 * Source code by tooluser from:
 * http://stackoverflow.com/questions/14094691/uitapgesturerecognizer-programmatically-trigger-a-tap-in-my-view
 *
 * With some little modification by Raymond Xie.
 */


#import "UITapGestureRecognizer+Spec.h"
#import "objc/runtime.h"

/*
 * With great contributions from Matt Gallagher (http://www.cocoawithlove.com/2008/10/synthesizing-touch-event-on-iphone.html)
 * And Glauco Aquino (http://stackoverflow.com/users/2276639/glauco-aquino)
 * And Codeshaker (http://codeshaker.blogspot.com/2012/01/calling-original-overridden-method-from.html)
 */
@interface UITapGestureRecognizer (Spec)

@property (strong, nonatomic, readwrite) UIView *mockTappedView_;
@property (assign, nonatomic, readwrite) CGPoint mockTappedPoint_;
@property (strong, nonatomic, readwrite) id mockTarget_;
@property (assign, nonatomic, readwrite) SEL mockAction_;

@end

NSString const *MockTappedViewKey = @"MockTappedViewKey";
NSString const *MockTappedPointKey = @"MockTappedPointKey";
NSString const *MockTargetKey = @"MockTargetKey";
NSString const *MockActionKey = @"MockActionKey";

@implementation UITapGestureRecognizer (Spec)

// It is necessary to call the original init method; super does not set appropriate variables.
// (eg, number of taps, number of touches, gods know what else)
// Swizzle our own method into its place. Note that Apple misspells 'swizzle' as 'exchangeImplementation'.
+(void)load {
    //NSLog(@"inject UITapGestureRecognizer");
    
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(initWithTarget:action:)),
                                   class_getInstanceMethod(self, @selector(initWithMockTarget:mockAction:)));
}

-(id)initWithMockTarget:(id)target mockAction:(SEL)action {
    //NSLog(@"initWithMockTarget, %@, %@", [target class], NSStringFromSelector(action));
    
    self = [self initWithMockTarget:target mockAction:action];
    self.mockTarget_ = target;
    self.mockAction_ = action;
    self.mockTappedView_ = nil;
    return self;
}

-(void)performTapWithView:(UIView *)view andPoint:(CGPoint)point {
    //NSLog(@"performTapWithView");
    
    self.mockTappedView_ = view;
    self.mockTappedPoint_ = point;
    
    // warning because a leak is possible because the compiler can't tell whether this method
    // adheres to standard naming conventions and make the right behavioral decision. Suppress it.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.mockTarget_ performSelector:self.mockAction_ withObject:self];
#pragma clang diagnostic pop
    
}

# pragma mark - Who says we can't add members in a category?

- (void)setMockTappedView_:(UIView *)mockTappedView {
    objc_setAssociatedObject(self, &MockTappedViewKey, mockTappedView, OBJC_ASSOCIATION_ASSIGN);
}

-(UIView *)mockTappedView_ {
    return objc_getAssociatedObject(self, &MockTappedViewKey);
}

- (void)setMockTappedPoint_:(CGPoint)mockTappedPoint {
    objc_setAssociatedObject(self, &MockTappedPointKey, [NSValue value:&mockTappedPoint withObjCType:@encode(CGPoint)], OBJC_ASSOCIATION_COPY);
}

- (CGPoint)mockTappedPoint_ {
    NSValue *value = objc_getAssociatedObject(self, &MockTappedPointKey);
    CGPoint aPoint;
    [value getValue:&aPoint];
    return aPoint;
}

- (void)setMockTarget_:(id)mockTarget {
    objc_setAssociatedObject(self, &MockTargetKey, mockTarget, OBJC_ASSOCIATION_ASSIGN);
}

- (id)mockTarget_ {
    return objc_getAssociatedObject(self, &MockTargetKey);
}

- (void)setMockAction_:(SEL)mockAction {
    objc_setAssociatedObject(self, &MockActionKey, NSStringFromSelector(mockAction), OBJC_ASSOCIATION_COPY);
}

- (SEL)mockAction_ {
    NSString *selectorString = objc_getAssociatedObject(self, &MockActionKey);
    return NSSelectorFromString(selectorString);
}


@end