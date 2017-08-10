//
//  UIViewController+AnimationHUD.h
//  MLTools
//
//  Created by Minlay on 16/9/20.
//  Copyright © 2016年 Minlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ShowHUD)
/**
 *  默认在当前view居中展示
 */
- (void)showHUD;
/**
 *  默认在当前view根据frame展示
 *
 */
- (void)showHUD:(CGRect)frame;
/**
 *  指定大小添加到指定的view展示
 *
 *  @param frame      size
 *  @param targetView 目标view
 */
- (void)showHUD:(CGRect)frame inView:(UIView *)targetView;
@end

@interface UIViewController (HideHUD)
/**
 *  移除HUD
 */
- (void)removeHUD;
/**
 *  指定移除目标view的HUD
 *
 *  @param targetView 目标view
 */
- (void)removeHUD:(UIView *)targetView;
@end

@interface UIViewController (NoDataHUD)

@end
typedef void (^completeBlock)();
@interface UIViewController (ReloadHUD)

- (void)showReloadHUD:(UIView *)superview callBack:(completeBlock)complete;

- (void)removeReloadHUD;
@end

@interface UIViewController (LoginHUD)

@end

@interface UIViewController (Message)
- (void)showMessage:(NSString *)message;
@end
