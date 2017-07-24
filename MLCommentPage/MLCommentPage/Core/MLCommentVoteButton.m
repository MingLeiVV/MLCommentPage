//
//  MLCommentVoteButton.m
//
//  Created by lei on 14-12-23.
//  Copyright (c) 2014年 . All rights reserved.
//

#import "MLCommentVoteButton.h"
@interface MLCommentVoteButton()
@property (retain, nonatomic) IBOutlet UILabel *voteCountLabel;
@property (retain, nonatomic) IBOutlet UIImageView *iconImageView;


@end
@implementation MLCommentVoteButton

+ (id)loadFromXib {
    @try{
        return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    } @catch (NSException *exception) {
        return nil;
    } @finally {
        
    }
}

-(void)setVoteCount:(NSString *)Count
{
    _voteCount = Count;
    _voteCountLabel.text = _voteCount;
}
- (void)setIcon:(NSString *)icon
{
    _icon = icon;
    _iconImageView.image = [UIImage imageNamed:icon];
}
- (void)setCountTextAlignment:(NSTextAlignment)countTextAlignment
{
    _voteCountLabel.textAlignment = countTextAlignment;
}
@end
