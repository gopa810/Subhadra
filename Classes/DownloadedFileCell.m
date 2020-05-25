//
//  DownloadedFileCell.m
//  VedabaseB
//
//  Created by Peter Kollath on 12/30/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import "DownloadedFileCell.h"

@implementation DownloadedFileCell

@synthesize button, titleText, progressView, file;

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

-(IBAction)onCancel:(id)sender
{
    if (button.selectedSegmentIndex == 0) {
        [file restart];
    } else {
        [file cancel];
    }
    button.selectedSegmentIndex = -1;
}

@end
