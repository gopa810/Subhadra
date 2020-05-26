//
//  VBContentManager.h
//  VedabaseB
//
//  Created by Peter Kollath on 20/09/14.
//
//

#import <Foundation/Foundation.h>

@class VBFolio;
@class VBFolioContentItem, CIBase;
@class CIModel, CIBookmarks, CINotes, CIHighlights, CIPlaylist, CIViewsRecord;

@interface VBContentManager : NSObject

@property (nonatomic) VBFolio * folio;
@property VBFolioContentItem * folioContent;
@property CIHighlights * itemHighlighters;
@property CIBookmarks * itemBookmarks;
@property CINotes * itemNotes;
@property CIViewsRecord * itemViews;
@property CIPlaylist * itemPlaylists;

@property (strong) NSString * lastPageType;

-(NSArray *)itemsForContentPage:(NSString *)page onlyContent:(BOOL)bOnlyContent;
-(NSArray *)itemsForRootPage:(BOOL)bOnlyContent;
-(void)addContentItems:(NSMutableArray *)contItems fromNode:(CIBase *)startItem isTop:(BOOL)bIsTop;
-(void)addContentItems:(NSMutableArray *)contItems fromContentItem:(VBFolioContentItem *)item onlyContent:(BOOL)bOnlyContent;
-(NSString *)findPageForRecord:(int)recId;
-(void)fillPath:(NSMutableArray *)path forRecord:(int)recId;
-(NSString *)findViewFromPath:(NSArray *)arr;

@end
