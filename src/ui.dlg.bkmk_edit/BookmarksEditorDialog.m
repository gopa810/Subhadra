//
//  BookmarksEditorDialog.m
//  VedabaseB
//
//  Created by Peter Kollath on 8/21/13.
//
//

#import "BookmarksEditorDialog.h"
#import "GetUserStringDialog.h"
#import "VBMainServant.h"
#import "VBFolio.h"
#import "VBBookmark.h"

@interface BookmarksEditorDialog ()

@end

@implementation BookmarksEditorDialog

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil mode:(int)nMode
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        p_mode = nMode;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.touchBack.hidden = YES;
    //self.touchBack.frame = self.view.frame;

    BookmarksListViewController * list = [[BookmarksListViewController alloc] initWithStyle:UITableViewStylePlain];
    self.bookmarkListController = list;
    list.skinManager = [VBMainServant skinManager];
    list.currentBookmarkParentId = -1;
    list.updateButton = self.btnUpdate;
    list.tableView = self.bookmarksTableView;
    list.view = self.bookmarksTableView;
    self.bookmarksTableView.dataSource = list;
    self.bookmarksTableView.delegate = list;
    [self.bookmarksTableView reloadData];

    
    // self properties
    
    self.view.backgroundColor = [list.skinManager colorForName:@"darkGradientA"];
    self.btnUpdate.alpha = 0.5;
    self.btnUpdate.enabled = NO;
    
}

-(void)notificationReceived:(NSNotification *)aNote
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction)onButtonUpdate:(id)sender {
    VBFolio * folio = [[VBMainServant instance] currentFolio];
    NSInteger selection = self.bookmarkListController.selectedBookmarkIndex;
    NSArray * bkmks = [folio bookmarksForParent:self.bookmarkListController.currentBookmarkParentId];
    if (selection >= 0 && selection < bkmks.count)
    {
        VBBookmark * bk = [bkmks objectAtIndex:selection];
        NSLog(@"Updating bookmark from %d to %d", bk.recordId, self.recordId);
        bk.recordId = self.recordId;
        bk.createDate = [NSDate date];
        if (bk.originalItem != nil) {
            bk.originalItem.recordId = self.recordId;
            bk.originalItem.createDate = [NSDate date];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBookmarksListChanged object:self];
        
        [self closeDialog];
    }
}

- (IBAction)onButtonCancel:(id)sender {
    //[self closeDialog];
    if (self.delegate && [self.delegate respondsToSelector:@selector(executeTouchCommand:data:)])
    {
        [self.delegate executeTouchCommand:@"closeBookmarkView" data:nil];
    }
}


@end
