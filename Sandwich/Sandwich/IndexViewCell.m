//
//  IndexViewCell.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/9/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "IndexViewCell.h"

@implementation IndexViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath fileName: (NSString*)fileName filePath:(NSString*)filePath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell"];
    
    UILabel *label;
    
    label = (UILabel *)[cell viewWithTag:1];
    label.text = [NSString stringWithFormat:@"%@", fileName];
    
    label = (UILabel *)[cell viewWithTag:2];
    label.text = [NSString stringWithFormat:@"%@", filePath];
    
    return cell;
}

@end
