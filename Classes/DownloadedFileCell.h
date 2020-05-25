//
//  DownloadedFileCell.h
//  VedabaseB
//
//  Created by Peter Kollath on 12/30/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolioFileDownloaded.h"

@interface DownloadedFileCell : UITableViewCell
{
    UILabel * titleText;
    UISegmentedControl * button;
    UIProgressView * progressView;
}

@property (nonatomic, retain) IBOutlet UILabel * titleText;
@property (nonatomic, retain) IBOutlet UISegmentedControl * button;
@property (nonatomic, retain) IBOutlet UIProgressView * progressView;
@property (nonatomic, assign) FolioFileDownloaded * file;

-(IBAction)onCancel:(id)sender;

@end
