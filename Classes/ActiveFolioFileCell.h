//
//  ActiveFolioFileCell.h
//  VedabaseB
//
//  Created by Peter Kollath on 12/29/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolioFileActive.h"

#define UPDATE_MODE_NONE    0
#define UPDATE_MODE_ENABLED 1
#define UPDATE_MODE_RUNNING 2

#define REMOVE_MODE_NONE     0
#define REMOVE_MODE_REMOVE   1
#define REMOVE_MODE_BUY      2
#define REMOVE_MODE_DOWNLOAD 3
#define REMOVE_MODE_UPDATE   4

#define kCellActionNone 0
#define kCellActionPayStarted 1
#define kCellActionBuyStarted 2

@interface ActiveFolioFileCell : UITableViewCell <UIAlertViewDelegate>
{
    IBOutlet UILabel  * labelTitle;
    IBOutlet UIProgressView * progressView;
    
    BOOL progressViewMode;
    NSInteger cellActionStatus;
    NSInteger _removeMode;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl * buttons;
@property (assign, readwrite) UITableView * tableView;
@property (assign, readwrite) NSInteger removeMode;
@property (nonatomic,copy) NSString * productIdentifier;
@property (assign) NSInteger cellActionStatus;
@property (nonatomic, retain) FolioFileActive * activeFolio;
@property (nonatomic, retain) FolioFileBase * availableFolio;

-(IBAction)onClickButtonUpdate:(id)sender;

-(void)setCellTitle:(NSString *)str;
-(NSString *)fileName;

@end
