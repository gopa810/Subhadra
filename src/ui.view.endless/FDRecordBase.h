//
//  FDRecordBase.h
//  VedabaseB
//
//  Created by Peter Kollath on 01/08/14.
//
//

#import <Foundation/Foundation.h>
@class FDPartBase;
@class FDParaFormat;
@class FDParagraph;
@class FDRecordPart;
@class FDRecordLocation;

@interface FDRecordBase : NSObject

@property (weak) UIView * recordView;
@property NSString * plainText;
@property (copy) NSString * levelName;
@property (copy) NSString * namedPopup;
@property BOOL noteIcon;
@property int recordId;
@property NSMutableArray * parts;
@property CGFloat calculatedWidth;
@property CGFloat calculatedHeight;
@property CGFloat calculatedMultiplyFontSize;
@property CGFloat calculatedMultiplyLineSize;
@property BOOL loading;
// 1 - align top of this to bottom of previous
// -1 = align bottom of this to top of next
@property int requestedAlign;
@property NSString * recordMark;
@property (strong, nonatomic) UIColor * recordMarkColor;
@property (nonatomic) int linkedRecordId;
@property CGFloat recordPaintOffset;

+(CGFloat)loadingRecordHeight;

-(CGFloat)validateForWidth:(CGFloat)width;
-(void)addElement:(FDPartBase *)sp;
-(void)setParaFormatting:(FDParaFormat *)aFormat;
-(FDParagraph *)getLastSafeParagraph;
-(FDRecordPart *)getCurrentPart;
-(id)getLastPart;
-(BOOL)testHit:(FDRecordLocation *)hr paddingLeft:(CGFloat)paddingLeft
  paddingRight:(CGFloat)paddingRight;
-(void)setNeedsRecalculate;
-(void)clearSelection;

-(void)selectPartsAroundHighlighting;
-(void)shrinkSelectedParts;
-(FDRecordBase *)lightCopy;

@end
