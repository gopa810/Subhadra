//
//  BottomBarView.m
//  VedabaseB
//
//  Created by Peter Kollath on 23/08/14.
//
//

#import "BottomBarView.h"
#import "BottomBarItem.h"


#define AUTOCORRECT_STEP 5
#define AUTOCORRECT_TIME 0.01

@implementation BottomBarView

-(void)myInit
{
    [super myInit];
    
    self.items = [[NSMutableArray alloc] init];
    self.currentOffset = 0;
    self.autocorrectOffset = YES;
    self.touchedItemIndex = -1;
    self.touchedBackColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    
    self.arrowAttrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:40],
                       NSFontAttributeName, [UIColor yellowColor], NSForegroundColorAttributeName, nil];
    self.leftExtremeArrow = @"\u2190";
    self.rightExtremeArrow = @"\u2192";
    self.prevDimensionValue = 0;

    self.sides = UIRectEdgeTop;
    
    [self setDimensions:768];
}

-(void)setDimensions:(CGFloat)portaitWidth
{
    if (fabs(self.prevDimensionValue - portaitWidth) < 2)
        return;
    
    self.prevDimensionValue = portaitWidth;
    
    CGFloat part = portaitWidth / 4;
    part = MIN(part, 96);
    
    self.itemWidth = part;
    self.iconHeight = part * 3 / 4;
    self.textHeight = part / 4;

    self.textProperties = [[NSMutableDictionary alloc] init];
    
    [self.textProperties setObject:[UIColor whiteColor]
                            forKey:NSForegroundColorAttributeName];
    [self.textProperties setObject:[UIFont systemFontOfSize:(part / 8)]
                            forKey:NSFontAttributeName];
    NSMutableParagraphStyle * ps = [[NSMutableParagraphStyle alloc] init];
    ps.alignment = NSTextAlignmentCenter;
    [self.textProperties setObject:ps
                            forKey:NSParagraphStyleAttributeName];

}

-(CGSize)calculateImageSize:(CGSize)size
{
    CGSize a, b;
    if (size.height != self.iconHeight && size.height > 0)
    {
        CGFloat ratio = self.iconHeight / size.height;
        a.height = self.iconHeight;
        a.width = size.width * ratio;
    }
    if (size.width > 0)
    {
        CGFloat ratio = (self.itemWidth - 8) / size.width;
        b.width = self.itemWidth - 8;
        b.height = size.width * ratio;
    }
    
    if ((b.width + b.height) > (a.width + a.height))
    {
        return a;
    }
    else
    {
        return b;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGFloat startX = rect.size.width / 2 +  self.currentOffset - self.itemWidth / 2;
    CGFloat startY;
 
    if (self.backgroundImage)
    {
        [self.backgroundImage drawInRect:rect];
    }

    int idx = 0;
    int cols = [self columnsCountForWidth:self.frame.size.width];
    int rows = [self rowsCountForColumns:cols];
    
    int sum = (int)self.items.count;
    int rowcols = 0;
    CGFloat currStartOffset = 0;

    for(int r = 0; r < rows; r++)
    {
        rowcols = MIN(sum, cols);
        currStartOffset = (self.frame.size.width - rowcols*self.itemWidth) / 2;
        for (int c = 0; c < rowcols; c++)
        {
            startX = c * self.itemWidth + currStartOffset;
            startY = r * self.itemWidth + 12;
            idx = r*cols + c;
            BottomBarItem * bi = [self.items objectAtIndex:idx];
            bi.itemRect = CGRectMake(startX, startY +8, self.itemWidth, self.itemWidth + 12);
            bi.itemIndex = idx;
            if (idx == self.touchedItemIndex)
            {
                CGContextRef ctx = UIGraphicsGetCurrentContext();
                CGContextSaveGState(ctx);
                CGContextAddRect(ctx, bi.itemRect);
                CGContextSetFillColorWithColor(ctx, self.touchedBackColor.CGColor);
                CGContextFillPath(ctx);
                CGContextRestoreGState(ctx);
            }
            
            if (bi.icon) {
                CGSize size = [self calculateImageSize:bi.icon.size];
                [bi.icon drawInRect:CGRectMake(startX + self.itemWidth/2 - size.width/2,
                                               startY + self.iconHeight / 2 - size.height / 2 + 8,
                                               size.width, size.height)];
            }
            
            if (bi.text) {
                CGRect textRect = CGRectMake(startX, startY + self.iconHeight + 12, self.itemWidth, self.textHeight);
                [bi.text drawInRect:textRect
                     withAttributes:self.textProperties];
            }
        }
        
        sum -= cols;
    }
    
}

-(void)planRepaint
{
    [self setNeedsDisplay];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint cp = [[touches anyObject] locationInView:self];
    self.touchedItemIndex = [self determineItem:cp];
    if (self.touchedItemIndex >= 0)
        [self setNeedsDisplay];
}


-(int)determineItem:(CGPoint)cp
{
    for (BottomBarItem * bi in self.items)
    {
        if (CGRectContainsPoint(bi.itemRect, cp))
        {
            return bi.itemIndex;
        }
    }

    return -1;
}

-(int)columnsCountForWidth:(CGFloat)width
{
    return (int)(width / self.itemWidth);
}

-(int)rowsCountForColumns:(int)cols
{
    return (int)self.items.count / cols + ((self.items.count % cols) > 0 ? 1 : 0);
}

-(CGFloat)calculateHeight:(CGRect)parentFrame
{
    CGFloat dim = MIN(parentFrame.size.height, parentFrame.size.width);
    [self setDimensions:dim];
    
    int colNum = [self columnsCountForWidth:parentFrame.size.width];
    
    int rows = [self rowsCountForColumns:colNum];
    
    return rows * self.itemWidth + 24;
    
}

@end
