//
//  NSArray+Log.m
//  Qdaily
//
//  Created by Envy15 on 16/8/14.
//  Copyright © 2016年 c344081. All rights reserved.
//

#import <objc/runtime.h>

static NSString * unicodeTransliterator (NSString *string, NSString *transform, BOOL reverse) {
    if ([string respondsToSelector:@selector(stringByApplyingTransform:reverse:)]) {
        return [string stringByApplyingTransform:transform reverse:reverse];
    }
    NSMutableString *strM = [string mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)(strM), NULL, (__bridge CFStringRef)(transform), reverse);
    return [strM copy];
}

@implementation NSArray (Log)


+ (void)load {
    Method m1 = class_getInstanceMethod([self class], @selector(descriptionWithLocale:));
    Method m2 = class_getInstanceMethod([self class], @selector(_descriptionWithLocale:));
    
    method_exchangeImplementations(m1, m2);
}

- (NSString *)_descriptionWithLocale:(id)locale {
    NSString *des = [self _descriptionWithLocale:locale];
    des = [des stringByReplacingOccurrencesOfString:@"\\U" withString:@"\\u"];
    
    return unicodeTransliterator(des, @"Any-Hex", YES);
}

@end

@implementation NSDictionary (Log)


+ (void)load {
    Method m1 = class_getInstanceMethod([self class], @selector(descriptionWithLocale:));
    Method m2 = class_getInstanceMethod([self class], @selector(_descriptionWithLocale:));
    
    method_exchangeImplementations(m1, m2);
}

- (NSString *)_descriptionWithLocale:(id)locale {
    NSString *des = [self _descriptionWithLocale:locale];
    des = [des stringByReplacingOccurrencesOfString:@"\\U" withString:@"\\u"];
    
    return unicodeTransliterator(des, @"Any-Hex", YES);
}

@end
