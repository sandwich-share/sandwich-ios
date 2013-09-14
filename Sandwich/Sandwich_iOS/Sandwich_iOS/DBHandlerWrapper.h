//
//  DBHandlerWrapper.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 9/13/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBHandlerWrapper : NSObject
- (id) initWithHandler:(sqlite3*)handler;
- (sqlite3*) unwrap;
@end
