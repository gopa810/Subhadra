//
//  CIBase.h
//  VedabaseB
//
//  Created by Peter Kollath on 9/1/13.
//
//

#import <Foundation/Foundation.h>
#import "ContentItemConstants.h"
#import "VBFolioStorageObjects.h"
#import "VBSkinManager.h"

@class ContentTableCell;

@interface CIBase : NSObject
{
    //CIBase * __weak   parent;
	//CIBase * __strong next;
	//CIBase * __strong prev;
	NSMutableArray * children;
    //NSString * p_name;
}

@property float paddingLeft;
@property float paddingRight;
@property float paddingTop;
@property float paddingBottom;
// 1-left, 2-center, 3-right, 4-justify
@property int textAlign;
@property int textSizeIndex;


//@property (strong) VBFolioContentItem * folioContentItem;
@property (weak) CIBase * parent;
@property CIBase * prev;
@property UIColor * lineColor;
@property CIBase * next;
@property BOOL expanded;
@property unsigned int level;
@property (weak) ContentTableCell * cell;
@property NSString * name;
@property int recordId;
@property (assign) int parentId;
@property NSString * pageDesc;
@property int selected;

// drawing properties
@property BOOL iconsValid;
@property UIImage * iconCheck;
@property UIImage * iconExpand;
@property UIImage * iconGoto;
@property int drawingPartTouched;
@property NSString * defaultTextStyle;
@property int drawingLayout;

-(NSString *)subtitleText;
-(int)titleLinesCount;
-(CIBase *)addItem:(CIBase *)newChild;
-(void)removeAllObjects;
-(CIBase *)itemAtIndex:(NSUInteger)index;
-(NSInteger)count;
-(NSMutableArray *)getChildren;
-(CIBase *)itemForName:(NSString *)strName;
-(CIBase *)findChild:(NSString *)lookId;
-(int)calculateNewStatus;
-(int)selectParentExpanded;
-(int)selectChildrenExpanded:(int)status;
-(void)propagateStatusToChildren:(int)status;
-(void)propagateNewStatusToParent:(int)status;
-(BOOL)hasChild;
-(BOOL)canSelect;
-(BOOL)canNavigate;
-(BOOL)hasExpandIcon;
-(NSString *)expandedImageName;
-(NSString *)collapsedImageName;
-(UIColor *)titleColor;
-(UIColor *)subtitleColor;
-(NSString *)expandOperation;
-(CIBase *)findPage:(int)pageNo;
-(UIColor *)backgroundColor:(VBSkinManager *)skinManager;

-(CGFloat)calculateHeightForWidth:(CGFloat)width fontBook:(NSDictionary *)fontBook;
-(int)determineLayout;
-(void)drawRect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook;
-(void)drawText:(NSString *)text rect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook;
-(NSDictionary *)createParaFormatingWithFont:(UIFont *)font align:(int)align color:(UIColor *)color;

// for subclasses only:
-(CGFloat)calculateHeightForText:(NSString *)text font:(UIFont *)font width:(CGFloat)width;
-(CGFloat)correctWidth:(CGFloat)width forLayout:(int)layout;
-(void)determineIcons:(VBSkinManager *)skinManager;
- (void)releaseIconsForLayout:(int)layout;
-(void)drawGradientSeparator:(UIImage *)greyLine inRect:(CGRect)rect;
- (void)drawBottomLine:(VBSkinManager *)skinManager rect:(CGRect)rect;
-(NSString *)getActionAtPoint:(CGPoint)location;
-(CGRect)getTouchRectAtPoint:(CGPoint)pt;
@end
