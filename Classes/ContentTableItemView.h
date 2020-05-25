//
//  ContentTableItemView.h
//  VedabaseB
//
//  Created by Peter Kollath on 20/09/14.
//
//

#import <UIKit/UIKit.h>
#import "ContentItemConstants.h"

@class ContentTableController;
@class CIBase;
@class VBUserInterfaceManager, VBSkinManager;

@interface ContentTableItemView : UIView

@property (weak) ContentTableController * tableController;
@property CIBase * data;
@property VBUserInterfaceManager * userInterfaceManager;
@property VBSkinManager * skinManager;
@property NSInteger itemIndex;
@property UILongPressGestureRecognizer * longPressRecognizer;
@property NSIndexPath * indexPath;

@property int drawingLayout;
@property int drawingPartTouched;
@property NSString * touchActionStart;

+(NSDictionary *)fontBook;
+ (void)initializeFontBook:(CGFloat)fontSizeNormal;
+(CGFloat)resolveFontSizeFromIndex:(NSInteger)fontSizeIndex;

@end
