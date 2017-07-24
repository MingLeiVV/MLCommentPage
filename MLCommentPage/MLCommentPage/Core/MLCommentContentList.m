//
//  MLCommentContentList.m
//
//  Created by lei on 13-11-29.
//  Copyright (c) 2013年 . All rights reserved.
//

#import "MLCommentContentList.h"
#import "MLComment.h"

@interface MLCommentContentList()

@property(retain)NSMutableArray* contentObjects;
@property(retain)NSMutableArray* orderList;
@property(retain)NSMutableDictionary* relationList;
@property(retain)NSMutableArray* hotList;
@property(retain)NSDictionary* news;

@property(retain)NSLock* lock;


-(void)initAllObjects;

@end

@implementation MLCommentContentList

@synthesize contentObjects=mContentObjects,relationList=mRelationList,orderList=mOrderList,news=mNews, hotList = mHotLost;
@synthesize lock=mLock;

-(id)init
{
    self = [super init];
    if (self) {
        mLock = [[NSLock alloc] init];
    }
    return self;
}


-(void)initAllObjects
{
    if (!self.contentObjects) {
        self.contentObjects = ([[NSMutableArray alloc] initWithCapacity:0]);
    }
    if (!self.orderList) {
        self.orderList = ([[NSMutableArray alloc] initWithCapacity:0]);
    }
    if (!self.relationList) {
        self.relationList = ([[NSMutableDictionary alloc] initWithCapacity:0]);
    }
    
    if (!self.hotList) {
        self.hotList = ([[NSMutableArray alloc] initWithCapacity:0]);
    }
}

-(void)refreshFromAnotherMLCommentContentList:(MLCommentContentList*)list
{
    [self initAllObjects];
    [self.lock lock];
    [self.orderList removeAllObjects];
    [self.relationList removeAllObjects];
    self.news = nil;
    [self.lock unlock];
    [self addFromAnotherMLCommentContentList:list];
}

-(void)addFromAnotherMLCommentContentList:(MLCommentContentList*)list
{
    [self initAllObjects];
    [self.lock lock];
    [self.orderList addObjectsFromArray:list.orderList];
    [self.relationList addEntriesFromDictionary:list.relationList];
    self.news = list.news;
    [self.lock unlock];
}

-(void)refreshContentObjectsWithOrderList:(NSArray*)orderList relationList:(NSDictionary*)relationList hotList:(NSArray*)hotList news:(NSDictionary*)news
{
    [self initAllObjects];
    [self.lock lock];
    [self.orderList removeAllObjects];
    [self.relationList removeAllObjects];
    [self.hotList removeAllObjects];
    self.news = nil;
    [self.lock unlock];
    [self addContentObjectsWithOrderList:orderList relationList:relationList hotList:hotList news:news];
}

-(void)addContentObjectsWithOrderList:(NSArray*)orderList relationList:(NSDictionary*)relationList  hotList:(NSArray*)hotList news:(NSDictionary*)news
{
    [self initAllObjects];
    [self.lock lock];
    [self.orderList addObjectsFromArray:[MLComment mj_objectArrayWithKeyValuesArray:orderList]];
    
    [self.orderList enumerateObjectsUsingBlock:^(MLComment *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary* modelDict = [[NSMutableDictionary alloc]init];
        NSArray *replay = obj.replay;
        if (replay && replay.count > 0) {
            NSArray* models = [MLComment mj_objectArrayWithKeyValuesArray:replay];
            [modelDict setValue:models forKey:obj.mid];
        }
        [self.relationList addEntriesFromDictionary:modelDict];
    }];
//    if ([relationList isKindOfClass:[NSDictionary class]]) {
//        NSMutableDictionary* modelDict = [[NSMutableDictionary alloc]init];
//        [relationList enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//            if ([obj isKindOfClass:[NSArray class]]) {
//                NSArray* models = [MLComment modelsWithDicArray:(NSArray*)obj];
//                [modelDict setValue:models forKey:key];
//            }
//        }];
//        
//        [self.relationList addEntriesFromDictionary:modelDict];
//    }
    
    
    [self.hotList addObjectsFromArray:[MLComment mj_objectArrayWithKeyValuesArray:hotList]];
    self.news = news;
    [self.lock unlock];
}

-(NSInteger)countOfOrderList
{
    [self.lock lock];
    NSInteger orderListCount = [self.orderList count];
    [self.lock unlock];
    return orderListCount;
}
-(NSInteger)countOfHotList
{
    [self.lock lock];
    NSInteger hotListCount = [self.hotList count];
    [self.lock unlock];
    return hotListCount;
}

-(NSArray*)contentObjectsWithIndex:(NSInteger)index
{
    NSMutableArray* rtval = [NSMutableArray arrayWithCapacity:0];
    [self.lock lock];
    if (index<[self.orderList count]) {
        MLComment* commentModel = [self.orderList objectAtIndex:index];
        NSString* mid = commentModel.mid;
        NSArray* relationModels = [self.relationList objectForKey:mid];
        [rtval addObject:commentModel];
        [rtval addObjectsFromArray:relationModels];
    }
    [self.lock unlock];
    
    return rtval;
}
-(NSArray*)hotObjectsWithIndex:(NSInteger)index
{
    NSMutableArray* rtval = [NSMutableArray arrayWithCapacity:0];
    if (index >= [self.hotList count]) {
        return nil;
    }
    [self.lock lock];
    MLComment* model =  [self.hotList objectAtIndex:index];
    [rtval addObject:model];
    [self.lock unlock];
    return rtval;
}
- (void)insertContent:(MLComment*)newModel ReplyModel:(MLComment*)replyModel
{
    if (replyModel) {
        NSString* mid = replyModel.mid;
        NSMutableArray* relationArray = [self.relationList objectForKey:mid];
        //新组建一栋楼
        NSMutableArray* newRelations = [NSMutableArray arrayWithArray:relationArray];
        [self.lock lock];
        [newRelations addObject:replyModel];
        [self.relationList setObject:newRelations forKey:newModel.mid];//用新发布mid
    }
    
    //将新发布的评论写入commentlist
    [self.orderList insertObject:newModel atIndex:0];
    [self.lock unlock];
}
@end
