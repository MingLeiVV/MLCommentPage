//
//  NSArray+Safe.h
//  MLTools
//
//  Created by Minlay on 16/9/19.
//  Copyright © 2016年 Minlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Safe)
/**
 *  get
 */
- (id)safeObjectAtIndex:(NSUInteger)index;

@end

@interface NSMutableArray (setValue)
/**
 *  set
 *
 */
- (void)safeAddObject:(id)object;
- (void)safeAddNilObject;
- (void)safeInsertObject:(id)object atIndex:(NSUInteger)index;
- (void)safeRemoveObject:(id)object;

@end