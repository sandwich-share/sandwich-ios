//
//  SearchResults.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/25/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peer.h"

@interface SearchResults : NSObject

- (void) addResult:(Peer*)peer filePath:(NSString*)filePath;
- (id) initResult: (Peer*)peer filePath:(NSString*)filePath;
@end
