//
//  DBHandlerWrapper.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 9/13/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "DBHandlerWrapper.h"

@implementation DBHandlerWrapper {
sqlite3* Handler;
}
- (id)initWithHandler:(sqlite3 *)handler {
    self = [super init];
    Handler = handler;
    return self;
}

- (sqlite3 *)unwrap {
    return Handler;
}

@end
