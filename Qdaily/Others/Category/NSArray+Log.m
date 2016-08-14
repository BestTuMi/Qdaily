//
//  NSArray+Log.m
//  Qdaily
//
//  Created by Envy15 on 16/8/14.
//  Copyright © 2016年 c344081. All rights reserved.
//

#import <objc/runtime.h>



@implementation NSArray (Log)


+ (void)load {
    Method m1 = class_getInstanceMethod([self class], @selector(descriptionWithLocale:));
    Method m2 = class_getInstanceMethod([self class], @selector(_descriptionWithLocale:));
    
    method_exchangeImplementations(m1, m2);
}

- (NSString *)_descriptionWithLocale:(id)locale {
    NSString *des = [self _descriptionWithLocale:locale];
    des = [des stringByReplacingOccurrencesOfString:@"\\U" withString:@"\\u"];
    
    return [des stringByApplyingTransform:@"Any-Hex" reverse:YES];
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
    
    return [des stringByApplyingTransform:@"Any-Hex" reverse:YES];
}

@end
