//
//  DownloadController.h
//  Sandwich
//
//  Created by Diego Waxemberg on 4/12/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadController : UIViewController <UIAlertViewDelegate>
@property NSString* filePath;

- (DownloadController*) initWithFilePath: (NSString*)filePath;

@end
