//
//  IndexDownloader.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/26/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peer.h"

@interface IndexDownloader : NSOperation

-(id) initWithPeer:(Peer*)peer;

@end
