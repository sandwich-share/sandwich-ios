//
//  Search.h
//  Sandwich
//
//  Created by Diego Waxemberg on 4/8/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Search : NSOperation
@property NSString* searchParam;

-(Search*)initWithSearchParam: (NSString*)searchParam;

@end
