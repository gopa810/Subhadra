//
//  BookmarksListViewController.h
//  VedabaseB
//
//  Created by Peter Kollath on 8/21/13.
//
//

#import <UIKit/UIKit.h>
#import "VBFolio.h"
#import "VBSkinManager.h"

@interface BookmarksListViewController : UITableViewController
{
    VBFolio * folio;
}

@property (assign) NSInteger selectedBookmarkIndex;
@property (retain, nonatomic) UIView * selectedBackgroundView;
@property (weak) UIButton * updateButton;
@property NSInteger currentBookmarkParentId;
@property NSArray * list;
@property VBSkinManager * skinManager;


@end
