//
//  QDUserAccountModel.m
//  Qdaily
//
//  Created by Envy15 on 15/10/27.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDUserAccountModel.h"

@interface QDUserAccountModel () <NSCoding>

@end

@implementation QDUserAccountModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.face forKey:@"face"];
    [aCoder encodeObject:self.expirationDate forKey:@"expirationDate"];
    [aCoder encodeInteger:self.type forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.token = [aDecoder decodeObjectForKey:@"token"];
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.face = [aDecoder decodeObjectForKey:@"face"];
        self.expirationDate = [aDecoder decodeObjectForKey:@"expirationDate"];
        self.type = [aDecoder decodeIntegerForKey:@"type"];
    }
    return self;
}

- (BOOL)saveUserAccount {
    return [NSKeyedArchiver archiveRootObject:self toFile:QDUserAccountFilePath];
}

@end
