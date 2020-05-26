//
//  VCContent.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/21/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CIModel.h"
#import "VBMainServant.h"
#import "VBFolioStorage.h"
#import "CINotes.h"
#import "CIHighlights.h"
#import "CIBookmarks.h"
#import "ContentPageDelegate.h"
#import "GetUserStringDelegate.h"
#import "SelectUserStringDelegate.h"

@class VBFolio, ContentPageController, VBContentManager, VBUserInterfaceManager;
@class ContentTableItemView;

@interface ContentTableController : UITableViewController<GetUserStringDelegate,SelectUserStringDelegate> {

	NSMutableArray * contItems;
    NSInteger bookmarksContentItemIndex;
    NSInteger notesContentItemIndex;
    NSInteger highlightersContentItemIndex;
    NSInteger topItemsOffset;
    
    CIHighlights * itemHighlighters;
    CIBookmarks * itemBookmarks;
    CINotes * itemNotes;
    NSUInteger lastContentDecoratorsToken;
}

@property VBContentManager * contentManager;
@property VBUserInterfaceManager * userInterfaceManager;
@property CIModel * folioContent;
@property CIBase * itemToRemove;
@property id<ContentPageDelegate> contentPageDelegate;
@property (weak) ContentPageController * parent;
@property UILongPressGestureRecognizer * longPressRecognizer;
@property NSMutableDictionary * editMenuActionsData;
@property (copy) NSString * lastPageLoaded;
@property int startingRecord;
@property NSMutableDictionary * pagePositions;

+(BOOL)isEditmenuVisible;

-(void)reloadStartPage;
-(void)activateCellAtPoint:(CGPoint)point;
-(void)setFolio:(VBFolio *)folio;
-(void)contentTableCell:(ContentTableItemView *)cell touchedPart:(int)part;
-(void)handleLongPressFromItem:(CIBase *)item recognizer:(UILongPressGestureRecognizer *)recognizer;
-(void)loadParentIfPossible;
-(void)loadItems:(NSString *)pageDesc;
-(void)executeAction:(NSString *)text;
-(void)reloadItems;

@end
