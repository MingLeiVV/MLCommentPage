//
//  UIView+Position.m
//  MLTools
//
//  Created by Minlay on 16/9/19.
//  Copyright © 2016年 Minlay. All rights reserved.
//

#import "UIView+Position.h"

UIInterfaceOrientation ITTInterfaceOrientation() {
    UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
    return orient;
}

CGRect ITTScreenBounds() {
    CGRect bounds = [UIScreen mainScreen].bounds;
    if (UIInterfaceOrientationIsLandscape(ITTInterfaceOrientation())) {
        CGFloat width = bounds.size.width;
        bounds.size.width = bounds.size.height;
        bounds.size.height = width;
    }
    return bounds;
}
@implementation UIView (Position)
- (CGFloat)x {
    return self.frame.origin.x;
}
- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}
- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)left {
    return self.frame.origin.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)top {
    return self.frame.origin.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerX {
    return self.center.x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)centerY {
    return self.center.y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)width {
    return self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)height {
    return self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)ttScreenX {
    CGFloat x = 0;
    for (UIView* view = self; view; view = view.superview) {
        x += view.left;
    }
    return x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)ttScreenY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.top;
    }
    return y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)screenViewX {
    CGFloat x = 0;
    for (UIView* view = self; view; view = view.superview) {
        x += view.left;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            x -= scrollView.contentOffset.x;
        }
    }
    
    return x;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)screenViewY {
    CGFloat y = 0;
    for (UIView* view = self; view; view = view.superview) {
        y += view.top;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)screenFrame {
    return CGRectMake(self.screenViewX, self.screenViewY, self.width, self.height);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)origin {
    return self.frame.origin;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)size {
    return self.frame.size;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)orientationWidth {
    return UIInterfaceOrientationIsLandscape(ITTInterfaceOrientation())
    ? self.height : self.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)orientationHeight {
    return UIInterfaceOrientationIsLandscape(ITTInterfaceOrientation())
    ? self.width : self.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)descendantOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls])
        return self;
    
    for (UIView* child in self.subviews) {
        UIView* it = [child descendantOrSelfWithClass:cls];
        if (it)
            return it;
    }
    
    return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)ancestorOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls]) {
        return self;
        
    } else if (self.superview) {
        return [self.superview ancestorOrSelfWithClass:cls];
        
    } else {
        return nil;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAllSubviews {
    while (self.subviews.count) {
        UIView* child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGPoint)offsetFromView:(UIView*)otherView {
    CGFloat x = 0, y = 0;
    for (UIView* view = self; view && view != otherView; view = view.superview) {
        x += view.left;
        y += view.top;
    }
    return CGPointMake(x, y);
}

- (void)halfSize {
    self.size = CGSizeMake(self.size.width/2, self.size.height/2);
}

- (UIViewController *)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigation = (UINavigationController *)nextResponder;
            return navigation.visibleViewController;
        }
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (UINavigationController *)navgationController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            
            UIViewController *nextViewController = (UIViewController *)nextResponder;
            UINavigationController *nav = nextViewController.navigationController;
            if (nav && [nav isKindOfClass:[UINavigationController class]]) {
                return nav;
            }
        }
    }
    return nil;
}

- (UIView*)findFirstResponderInView:(UIView*)topView {
    if ([topView isFirstResponder]) {
        return topView;
    }
    
    for (UIView* subView in topView.subviews) {
        if ([subView isFirstResponder]) {
            return subView;
        }
        
        UIView* firstResponderCheck = [self findFirstResponderInView:subView];
        if (nil != firstResponderCheck) {
            return firstResponderCheck;
        }
    }
    return nil;
}

- (UIView *)findScrollViewInView:(UIView *)topView {
    if ([topView isKindOfClass:[UIScrollView class]]) {
        return topView;
    }
    
    for (UIView* subView in topView.subviews) {
        if ([subView isKindOfClass:[UIScrollView class]]) {
            return subView;
        }
        
        UIView* firstResponderCheck = [self findScrollViewInView:subView];
        if (nil != firstResponderCheck) {
            return firstResponderCheck;
        }
    }
    return nil;
}

- (instancetype)findViewWithTag:(NSInteger)tag InView:(UIView *)topView {
    
    if (tag == topView.tag) {
        return topView;
    }
    
    for (UIView* subView in topView.subviews) {
        if (tag == subView.tag) {
            return subView;
        }
        
        UIView* viewCheck = [self findViewWithTag:tag InView:subView];
        if (nil != viewCheck) {
            return viewCheck;
        }
    }
    return nil;
}

+ (void)layoutSubviewsHorizontally:(NSArray *)subviews insets:(UIEdgeInsets)insets verticalAlignment:(UIControlContentVerticalAlignment)verticalAlignment inFrame:(CGRect)frame {
    NSMutableArray *visibleSubviews = [NSMutableArray arrayWithArray:subviews];
    NSIndexSet *indexes = [visibleSubviews indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isHidden];
    }];
    [visibleSubviews removeObjectsAtIndexes:indexes];
    
    NSUInteger subviewsCount = visibleSubviews.count;
    if (0 == subviewsCount) {
        return;
    }
    
    if (1 == subviewsCount) {
        UIView *subview = [visibleSubviews objectAtIndex:0];
        if (0 == insets.left && 0 == insets.right) {
            subview.centerX = CGRectGetMidX(frame);
        }else if (insets.left) {
            subview.left = CGRectGetMinX(frame) + insets.left;
        }else {
            subview.right = CGRectGetMaxX(frame) - insets.right;
        }
        if (insets.top) {
            subview.top = CGRectGetMinY(frame) + insets.top;
        }else if (insets.bottom) {
            subview.bottom = CGRectGetMaxY(frame) - insets.bottom;
        }else {
            //没有设置insets的top或者bottom，使用verticalAlignment
            if (UIControlContentVerticalAlignmentTop == verticalAlignment) {
                subview.top = CGRectGetMinY(frame);
            }else if (UIControlContentVerticalAlignmentBottom == verticalAlignment) {
                subview.bottom = CGRectGetMaxY(frame);
            }else {
                subview.centerY = CGRectGetMidY(frame);
            }
        }
    }else {
        CGFloat totalSubviewsWidth = 0;
        for (UIView *subview in visibleSubviews) {
            totalSubviewsWidth += subview.width;
        }
        
        CGFloat spacing = (CGRectGetWidth(frame) - insets.left - insets.right - totalSubviewsWidth) / (subviewsCount - 1);
        CGFloat x = CGRectGetMinX(frame) + insets.left;
        CGFloat y;
        
        for (UIView *subview in visibleSubviews) {
            if (insets.top) {
                y = CGRectGetMinY(frame) + insets.top;
            }else if (insets.bottom) {
                y = CGRectGetMaxY(frame) - insets.bottom - subview.height;
            }else {
                //没有设置insets的top或者bottom，使用verticalAlignment
                if (UIControlContentVerticalAlignmentTop == verticalAlignment) {
                    y = CGRectGetMinY(frame);
                }else if (UIControlContentVerticalAlignmentBottom == verticalAlignment) {
                    y = CGRectGetMaxY(frame) - subview.height;
                }else {
                    y = CGRectGetMidY(frame) - subview.height / 2;
                }
            }
            subview.origin = CGPointMake(x, y);
            x += subview.width + spacing;
        }
    }
}


- (void)layoutSubviewsHorizontallyWithInsets:(UIEdgeInsets)insets verticalAlignment:(UIControlContentVerticalAlignment)verticalAlignment inFrame:(CGRect)frame {
    [UIView layoutSubviewsHorizontally:self.subviews insets:insets verticalAlignment:verticalAlignment inFrame:frame];
}

- (void)layoutSubviewsHorizontallyWithInsets:(UIEdgeInsets)insets verticalAlignment:(UIControlContentVerticalAlignment)verticalAlignment {
    [self layoutSubviewsHorizontallyWithInsets:insets verticalAlignment:verticalAlignment inFrame:self.bounds];
}

-(UIImage *)getImageFromView:(UIView *)orgView{
    UIGraphicsBeginImageContext(orgView.bounds.size);
    [orgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (void)setRoundArc:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}
@end
