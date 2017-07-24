//
//  MLCommentVoteButton.h
//
//  Created by lei on 14-12-23.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLCommentVoteButton : UIButton
@property(nonatomic,retain)NSString* voteCount;
@property(nonatomic,retain)NSString* icon;
@property(nonatomic,assign)NSTextAlignment countTextAlignment;
+ (id)loadFromXib;
@end
