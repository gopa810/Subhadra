//
//  FolioFilesTableViewController.h
//  VedabaseB
//
//  Created by Peter Kollath on 12/29/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActiveFolioFileCell.h"
#import "DownloadedFileCell.h"
#import "FolioFileDownloaded.h"

@interface FolioFilesTableViewController : UITableViewController <FolioFileDownloadingDelegate>
{
    DownloadedFileCell * loadedDownloadCell;
    ActiveFolioFileCell * loadedActiveCell;
    NSArray * sectionTitles;
    FolioFileBase * pendingFileItem;
    FolioFileBase * notAvailableFileItem;
}

@property (nonatomic, retain) IBOutlet ActiveFolioFileCell * loadedActiveCell;
@property (nonatomic, retain) IBOutlet DownloadedFileCell * loadedDownloadCell;

@end
