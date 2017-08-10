//
//  NSArray+Safe.m
//  MLTools
//
//  Created by Minlay on 16/9/19.
//  Copyright © 2016年 Minlay. All rights reserved.
//

#import "NSArray+Safe.h"

@implementation NSArray (Safe)
- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        return nil;
    }
    
    return [self objectAtIndex:index];
}
@end

@implementation NSMutableArray (setValue)
- (void)safeAddObject:(id)object
{
    if (object) {
        [self addObject:object];
    }
    else {
        
    }
}

- (void)safeAddNilObject
{
    [self addObject:[NSNull null]];
}

- (void)safeInsertObject:(id)object atIndex:(NSUInteger)index
{
    if (index > [self count]) {
        return;
    }
    if (object) {
        [self insertObject:object atIndex:index];
    }
    else {
        
    }
}

- (void)safeRemoveObject:(id)object
{
    if (object)
    {
        [self removeObject:object];
    }
    else
    {
        
    }
}
@end
