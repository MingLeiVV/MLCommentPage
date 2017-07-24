//
//  MLCommentContentList.h
//
//  Created by lei on 13-11-29.
//  Copyright (c) 2013年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@class MLComment;
@interface MLCommentContentList : NSObject
{
    NSMutableArray* mContentObjects;
    NSMutableArray* mOrderList;
    NSMutableDictionary* mRelationList;
    NSMutableArray* mHotLost;
    NSDictionary* mNews;
    NSLock* mLock;
}

-(void)addFromAnotherMLCommentContentList:(MLCommentContentList*)list;
-(void)refreshFromAnotherMLCommentContentList:(MLCommentContentList*)list;
-(void)refreshContentObjectsWithOrderList:(NSArray*)orderList relationList:(NSDictionary*)relationList hotList:(NSArray*)hotList news:(NSDictionary*)news;
-(void)addContentObjectsWithOrderList:(NSArray*)orderList relationList:(NSDictionary*)relationList hotList:(NSArray*)hotList news:(NSDictionary*)news;
-(NSInteger)countOfOrderList;
-(NSInteger)countOfHotList;
-(NSArray*)contentObjectsWithIndex:(NSInteger)index;
-(NSArray*)hotObjectsWithIndex:(NSInteger)index;

- (void)insertContent:(MLComment *)newModel ReplyModel:(MLComment *)replyModel;
@end
