//
//  ContentTableItemView.m
//  VedabaseB
//
//  Created by Peter Kollath on 20/09/14.
//
//

#import "ContentTableItemView.h"
#import "CIModel.h"
#import "VBFolioStorageObjects.h"
#import "VBUserInterfaceManager.h"
#import "VBSkinManager.h"
#import "ContentTableController.h"
#import "CIText.h"
#import "CIPlaylist.h"
#import "CIViewsRecord.h"

NSDictionary * boldBrownTextAttributes;
NSDictionary * regularBrownTextAttributes;
NSDictionary * titleTextAttributes;
NSDictionary * returnLabelAttributes;
NSDictionary * greenTechnicalAttributes;
NSDictionary * smallSubtext;
NSDictionary * italicBrownTextAttributes;
NSMutableDictionary * fontBook;
UIFont * boldFont;
UIFont * regularFont;
UIFont * italicFont;
UIFont * bigFont;
UIFont * smallerFont;

CGFloat CHECK_MARK_AREA_WIDTH;
CGFloat GOTO_MARK_AREA_WIDTH;


@implementation ContentTableItemView

+ (void)initializeFontBook:(CGFloat)fontSizeNormal
{
    boldFont = [UIFont boldSystemFontOfSize:fontSizeNormal];
    italicFont = [UIFont italicSystemFontOfSize:fontSizeNormal];
    regularFont = [UIFont systemFontOfSize:fontSizeNormal];
    bigFont = [UIFont systemFontOfSize:fontSizeNormal*1.7];
    smallerFont = [UIFont systemFontOfSize:fontSizeNormal*2/3];
    
    fontBook = [NSMutableDictionary new];
    [fontBook setValue:regularFont forKey:@"regular"];
    [fontBook setValue:smallerFont forKey:@"smaller"];
    [fontBook setValue:bigFont forKey:@"big"];
    [fontBook setValue:boldFont forKey:@"bold"];
    [fontBook setValue:italicFont forKey:@"italic"];
    
    [fontBook setValue:[UIFont systemFontOfSize:fontSizeNormal*1.75]
                forKey:@"fontR1"];
    [fontBook setValue:[UIFont systemFontOfSize:fontSizeNormal*1.5]
                forKey:@"fontR2"];
    [fontBook setValue:[UIFont systemFontOfSize:fontSizeNormal]
                forKey:@"fontR3"];
    [fontBook setValue:[UIFont systemFontOfSize:fontSizeNormal*0.8]
                forKey:@"fontR4"];
    [fontBook setValue:[UIFont systemFontOfSize:fontSizeNormal*0.6]
                forKey:@"fontR5"];
    
    UIColor * darkTextColor = [VBMainServant colorForName:@"darkTextColor"];
    UIColor * contentTextLink = [VBMainServant colorForName:@"contentTextLink"];
    UIColor * contentExtraText = [VBMainServant colorForName:@"contentExtraText"];
    //UIColor * lightTextColor = [VBMainServant colorForName:@"lightTextColor"];
    
    boldBrownTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                               darkTextColor, NSForegroundColorAttributeName,
                               boldFont,  NSFontAttributeName,
                               nil];
    italicBrownTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                 darkTextColor, NSForegroundColorAttributeName,
                                 italicFont,  NSFontAttributeName,
                                 nil];
    regularBrownTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                  contentTextLink, NSForegroundColorAttributeName,
                                  regularFont,  NSFontAttributeName,
                                  nil];
    greenTechnicalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                contentExtraText, NSForegroundColorAttributeName,
                                regularFont,  NSFontAttributeName,
                                nil];
    
    NSMutableParagraphStyle *paragraphRef = [NSMutableParagraphStyle new];
    paragraphRef.alignment = NSTextAlignmentCenter;
    
    titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:darkTextColor, NSForegroundColorAttributeName, bigFont, NSFontAttributeName, paragraphRef, NSParagraphStyleAttributeName,nil];
    returnLabelAttributes = [NSDictionary dictionaryWithObjectsAndKeys:darkTextColor, NSForegroundColorAttributeName, regularFont, NSFontAttributeName,nil];
    smallSubtext = [NSDictionary dictionaryWithObjectsAndKeys:contentExtraText, NSForegroundColorAttributeName, smallerFont, NSFontAttributeName, nil];
    
    [fontBook setValue:regularBrownTextAttributes forKey:@"styleM"];
    [fontBook setValue:boldBrownTextAttributes forKey:@"styleBM"];
    [fontBook setValue:smallSubtext forKey:@"styleS"];
    [fontBook setValue:greenTechnicalAttributes forKey:@"styleG"];
    [fontBook setValue:titleTextAttributes forKey:@"styleT"];
    [fontBook setValue:returnLabelAttributes forKey:@"styleR"];
    [fontBook setValue:italicBrownTextAttributes forKey:@"styleI"];
}

+(void)initialize
{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSInteger idx = [ud integerForKey:@"cont_text_size"];
    CGFloat fontSizeNormal = [ContentTableItemView resolveFontSizeFromIndex:idx];
    
    [ContentTableItemView initializeFontBook:fontSizeNormal];

}

+(CGFloat)resolveFontSizeFromIndex:(NSInteger)fontSizeIndex
{
    CGFloat fontSizeNormal;
    
    switch (fontSizeIndex)
    {
        case 0:
            fontSizeNormal = 9;
            CHECK_MARK_AREA_WIDTH = 40;
            GOTO_MARK_AREA_WIDTH = 40;
            break;
        case 1:
            fontSizeNormal = 11;
            CHECK_MARK_AREA_WIDTH = 44;
            GOTO_MARK_AREA_WIDTH = 44;
            break;
        case 2:
            fontSizeNormal = 13;
            CHECK_MARK_AREA_WIDTH = 48;
            GOTO_MARK_AREA_WIDTH = 48;
            break;
        case 4:
            fontSizeNormal = 18;
            CHECK_MARK_AREA_WIDTH = 56;
            GOTO_MARK_AREA_WIDTH = 56;
            break;
        case 3:
        default:
            fontSizeNormal = 16;
            CHECK_MARK_AREA_WIDTH = 52;
            GOTO_MARK_AREA_WIDTH = 52;
            break;
    }
    
    return fontSizeNormal;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:self.longPressRecognizer];
    }
    

    return self;
}


-(void)handleLongPress:(id)sender
{
    //CGPoint point = [self.longPressRecognizer locationInView:self];
    //NSLog(@"Handle long press....... %ld", (long)self.longPressRecognizer.state);
    if (self.longPressRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.tableController handleLongPressFromItem:self.data recognizer:self.longPressRecognizer];
    }
}

-(BOOL)checkMarkVisible
{
    return (self.drawingLayout == DL_CHECK_TEXT)
        || (self.drawingLayout == DL_CHECK_TEXT_GOTO)
    || (self.drawingLayout == DL_CHECK_TEXT_EXPAND)
    || (self.drawingLayout == DL_CHECK_TEXT_EXPAND_GOTO);
}

-(BOOL)gotoMarkVisible
{
    return (self.drawingLayout == DL_CHECK_TEXT_GOTO)
          || (self.drawingLayout == DL_CHECK_TEXT_EXPAND_GOTO);
}

-(BOOL)expandMarkVisible
{
    return (self.drawingLayout == DL_CHECK_TEXT_EXPAND)
        || (self.drawingLayout == DL_CHECK_TEXT_EXPAND_GOTO);
}

-(int)determineDrawingPart:(NSSet *)touches
{
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    int partTouched = 0;
    self.drawingLayout = self.data.drawingLayout;
    if (self.drawingLayout == DL_CHECK_TEXT)
    {
        if (location.x < CHECK_MARK_AREA_WIDTH)
        {
            partTouched = DP_CHECK;
        }
        else
        {
            partTouched = DP_TEXT;
        }
    }
    else if (self.drawingLayout == DL_CHECK_TEXT_GOTO)
    {
        if (location.x < CHECK_MARK_AREA_WIDTH)
        {
            partTouched = DP_CHECK;
        }
        else if (location.x > (self.bounds.size.width - GOTO_MARK_AREA_WIDTH))
        {
            partTouched = DP_GOTO;
        }
        else
        {
            partTouched = DP_TEXT;
        }
    }
    else if (self.drawingLayout == DL_CHECK_TEXT_EXPAND_GOTO)
    {
        if (location.x < CHECK_MARK_AREA_WIDTH)
        {
            partTouched = DP_CHECK;
        }
        else if (location.x > (self.bounds.size.width - GOTO_MARK_AREA_WIDTH))
        {
            partTouched = DP_GOTO;
        }
        else if (location.x > (self.bounds.size.width - 2*GOTO_MARK_AREA_WIDTH))
        {
            partTouched = DP_EXPAND;
        }
        else
        {
            partTouched = DP_TEXT;
        }
    }
    else if (self.drawingLayout == DL_CHECK_TEXT_EXPAND)
    {
        if (location.x < CHECK_MARK_AREA_WIDTH)
        {
            partTouched = DP_CHECK;
        }
        else if (location.x > (self.bounds.size.width - GOTO_MARK_AREA_WIDTH))
        {
            partTouched = DP_EXPAND;
        }
        else
        {
            partTouched = DP_TEXT;
        }
    }
    else if (self.drawingLayout == DL_ALL_TEXT)
    {
        partTouched = DP_TEXT;
    }
    return partTouched;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"touches began %@", ([ContentTableController isEditmenuVisible] ? @"- menu is visible" : @""));

    if ([ContentTableController isEditmenuVisible])
        self.drawingPartTouched = 0;
    else
    {
        UITouch * touch = [touches anyObject];
        CGPoint location = [touch locationInView:self];
        
        self.touchActionStart = [self.data getActionAtPoint:location];
        self.drawingPartTouched = [self determineDrawingPart:touches];
        [self setNeedsDisplay];
    }
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"CTIV - touches cancelled");
    self.drawingPartTouched = 0;
    [self setNeedsDisplay];
    [super touchesCancelled:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"CTIV - touches ended");
    self.drawingPartTouched = 0;
    if (![ContentTableController isEditmenuVisible])
    {
        UITouch * touch = [touches anyObject];
        CGPoint location = [touch locationInView:self];
        
        NSString * touchActionEnd = [self.data getActionAtPoint:location];
        
        if (touchActionEnd != nil && self.touchActionStart != nil && [touchActionEnd isEqualToString:self.touchActionStart])
        {
            [self.tableController executeAction:touchActionEnd];
            self.touchActionStart = nil;
        }
        else
        {
            [self.tableController contentTableCell:self
                                       touchedPart:[self determineDrawingPart:touches]];
        }
        [self setNeedsDisplay];
    }
    [super touchesEnded:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"CTIV - touches moved");
    [super touchesMoved:touches withEvent:event];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self.data drawRect:rect skinManager:self.skinManager fontBook:fontBook];
}

+(NSDictionary *)fontBook
{
    return fontBook;
}


@end
