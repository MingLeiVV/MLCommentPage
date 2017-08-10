//
//  UIViewController+AnimationHUD.m
//  MLTools
//
//  Created by Minlay on 16/9/20.
//  Copyright © 2016年 Minlay. All rights reserved.
//

#import "UIViewController+AnimationHUD.h"
#import "MLRefreshView.h"
#import "UILabel+Extention.h"
#import <objc/runtime.h>

#define SHOWTAG 1
#define NODATATAG 2
#define LOGINTAG 3
#define RELOADTAG 4
#define MESSAGETAG 5
@interface UIViewController ()
@property(nonatomic, copy)completeBlock reloadBlock;
@property(nonatomic, strong)UIView *containerView;
@end


@implementation UIViewController (ShowHUD)

- (void)showHUD {
    [self showHUD:self.view.bounds inView:self.view];
}
- (void)showHUD:(CGRect)frame {
    [self showHUD:frame inView:self.view];
}
- (void)showHUD:(CGRect)frame inView:(UIView *)targetView {
    MLRefreshView *mlRefreshView = [targetView viewWithTag:SHOWTAG];
    if (mlRefreshView) {
        [targetView bringSubviewToFront:mlRefreshView];
        return;
    }
    mlRefreshView = [MLRefreshView refreshViewWithFrame:frame logoStyle:RefreshLogoCommon];
    mlRefreshView.tag = SHOWTAG;
    targetView.userInteractionEnabled = NO;
    [targetView addSubview:mlRefreshView];
    [targetView bringSubviewToFront:mlRefreshView];
    [mlRefreshView startAnimation];
}
@end

@implementation UIViewController (HideHUD)
- (void)removeHUD {
    [self removeHUD:self.view];
}
- (void)removeHUD:(UIView *)targetView {
    if (!targetView) {
        return;
    }
    UIView *mlRefreshView = [targetView viewWithTag:SHOWTAG];
    if (!mlRefreshView) {
        return;
    }
    mlRefreshView.superview.userInteractionEnabled = YES;
    [mlRefreshView removeFromSuperview];
}
@end

@implementation UIViewController (NoDataHUD)

@end
static const char *reloadBlockKey = "reloadBlockKey";
static const char *containerViewKey = "containerViewKey";
@implementation UIViewController (ReloadHUD)
- (void)showReloadHUD:(UIView *)superview callBack:(completeBlock)complete {
    if (!superview) {
        superview = self.view;
    }
    if (self.containerView) return;
    self.reloadBlock = complete;
    [self setupView:superview];
}
- (void)removeReloadHUD {
    if (self.containerView) {
        if ([self.containerView.superview isKindOfClass:[UITableView class]]) {
            UITableView *table = (UITableView *)self.containerView.superview;
            table.scrollEnabled = YES;
        }
        [self.containerView removeFromSuperview];
        self.containerView = nil;
    }
}

- (void)setupView:(UIView *)superView {
    
    if ([superView isKindOfClass:[UITableView class]]) {
        UITableView *table = (UITableView *)superView;
        table.scrollEnabled = NO;
    }
    UIView *containerView = [[UIView alloc] init];
    self.containerView = containerView;
    [self addTapGesture:containerView];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.frame = superView.bounds;
    UIImageView *reloadTip = [self getReloadTip];
    UILabel *reloadTipLabel = [self getReloadTipLabel];
    [superView addSubview:containerView];
    [containerView addSubview:reloadTip];
    [containerView addSubview:reloadTipLabel];
    
    reloadTip.translatesAutoresizingMaskIntoConstraints = NO;
    [reloadTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(containerView);
    }];
    reloadTipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [reloadTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(reloadTip.mas_bottom).offset(10);
        make.centerX.equalTo(reloadTip);
    }];
}


/// 添加点击手势
- (void)addTapGesture:(UIView *)superview {
    [superview addGestureRecognizer: [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(performRefresh)]];
}
- (void)performRefresh {
    __weak typeof(self) weakSelf = self;
    if (weakSelf.reloadBlock) {
        weakSelf.reloadBlock();
    }
}
- (void)setReloadBlock:(completeBlock)reloadBlock {
 objc_setAssociatedObject(self, reloadBlockKey, reloadBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (completeBlock)reloadBlock {
    return objc_getAssociatedObject(self, reloadBlockKey);
}
- (void)setContainerView:(UIView *)containerView {
    objc_setAssociatedObject(self, containerViewKey, containerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIView *)containerView {
    return objc_getAssociatedObject(self, containerViewKey);
}
- (UIImageView *)getReloadTip {
    return [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"click-refresh-bgimg"]];
}
- (UILabel *)getReloadTipLabel {
    return [UILabel labelWithText:@"点击刷新" fontSize:17 textColor:RGBCOLOR(153, 153, 153)];
}

@end

@implementation UIViewController (LoginHUD)

@end

@implementation UIViewController (Message)
- (void)showMessage:(NSString *)message {
    
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView *showview =  [window viewWithTag:MESSAGETAG];
    if (showview) {
        [showview removeFromSuperview];
    }
    showview =  [[UIView alloc]init];
    showview.tag = MESSAGETAG;
    showview.backgroundColor = [UIColor blackColor];
    showview.frame = CGRectMake(1, 1, 1, 1);
    showview.alpha = 0.9f;
    showview.layer.cornerRadius = 10.0f;
    showview.layer.masksToBounds = YES;
    [window addSubview:showview];
    
    UILabel *label = [[UILabel alloc]init];
    CGSize LabelSize = [message sizeWithFont:[UIFont systemFontOfSize:18] constrainedToSize:CGSizeMake(290, 9000)];
    label.frame = CGRectMake(0, 0, LabelSize.width, LabelSize.height);
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:18];
    [showview addSubview:label];
    CGFloat insetW = 50;
    CGFloat insetH = 15;
    showview.frame = CGRectMake((SCREEN_WIDTH - LabelSize.width)/2 - insetW, (SCREEN_HEIGHT - LabelSize.height)/2  - insetH, LabelSize.width + 2 * insetW, LabelSize.height + insetH * 2);
    label.x = insetW;
    label.y = insetH;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            showview.alpha = 0;
        } completion:^(BOOL finished) {
            [showview removeFromSuperview];
        }];
    });
}
@end
