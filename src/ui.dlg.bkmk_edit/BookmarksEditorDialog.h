//
//  BookmarksEditorDialog.h
//  VedabaseB
//
//  Created by Peter Kollath on 8/21/13.
//
//

#import <UIKit/UIKit.h>
#import "VBDialogController.h"
#import "BookmarksListViewController.h"
#import "TGTouchArea.h"
#import "GetUserStringDelegate.h"

@interface BookmarksEditorDialog : VBDialogController <UIAlertViewDelegate>
{
    int p_mode;
}

@property (retain, nonatomic) IBOutlet TGTouchArea *touchBack;
@property (retain, nonatomic) IBOutlet UITableView *bookmarksTableView;
@property (retain, nonatomic) BookmarksListViewController * bookmarkListController;
@property (retain, nonatomic) IBOutlet UIButton *btnUpdate;

@property (assign) uint32_t recordId;
@property (assign) uint32_t globalRecordId;
@property NSInteger currentBookmarkId;

@property (retain,nonatomic) IBOutlet UIView * keyboardAccessory1;

@property (retain, nonatomic) UIAlertView * alertDelete;


- (IBAction)onButtonUpdate:(id)sender;
- (IBAction)onButtonCancel:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mode:(int)nMode;

@end
