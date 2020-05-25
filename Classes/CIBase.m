//
//  CIBase.m
//  VedabaseB
//
//  Created by Peter Kollath on 9/1/13.
//
//

#import "CIBase.h"

@implementation CIBase


@synthesize parent;
@synthesize prev;
@synthesize next;
@synthesize expanded;
@synthesize level;

-(id)init
{
    self = [super init];
    if (self) {
        self.paddingTop = AREA_INSET;
        self.paddingLeft = AREA_INSET;
        self.paddingRight = AREA_INSET;
        self.paddingBottom = AREA_INSET;
        self.iconsValid = NO;
        self.defaultTextStyle = @"styleM";
        self.drawingLayout = -1;
        self.textSizeIndex = 3;
        self.textAlign = 1;
    }
    return self;
}

-(CIBase *)addItem:(CIBase *)newChild
{
	if (children == nil)
	{
		children = [[NSMutableArray alloc] init];
	}
	if (children != nil)
	{
		newChild.parent = self;
		[children addObject:newChild];
		return newChild;
	}
	
	return nil;
}

-(CIBase *)findPage:(int)pageNo
{
    if (pageNo == 0)
        return self;
    
    return nil;
}

-(void)removeAllObjects
{
	if (children != nil)
	{
		[children removeAllObjects];
	}
}

-(NSInteger)count
{
	if (children != nil) return [children count];
	return 0;
}

-(CIBase *)itemAtIndex:(NSUInteger)index
{
	return [children objectAtIndex:index];
}

-(NSMutableArray *)getChildren
{
	return children;
}

-(CIBase *)itemForName:(NSString *)strName
{
    if ([children count] == 0)
        return nil;
    
    for(CIBase * cim in children)
    {
        if ([[cim name] caseInsensitiveCompare:strName] == NSOrderedSame)
            return cim;
    }
    
    return nil;
}

//
// lookId contains one-based index of item
// that means 1, 2, 3, .... N
//
-(CIBase *)findChild:(NSString *)lookId
{
	int idx = [lookId intValue] - 1;
	if (idx < 0 || idx >= [children count])
		return nil;
	return [children objectAtIndex:idx];
}

-(int)selectParentExpanded
{
	int count = 0;
	CIBase * par = self.parent;
	if (par)
	{
		int currentStatus = par.selected;
		int shouldBeStatus = [par calculateNewStatus];
		if (currentStatus != shouldBeStatus)
		{
			par.selected = shouldBeStatus;
			count++;
			count += [par selectParentExpanded];
		}
	}
	return count;
}

-(int)calculateNewStatus
{
	BOOL inits = NO;
	int status = NSOffState;
	for(CIBase * ci in children)
	{
		if (inits == NO)
		{
			status = ci.selected;
			inits = YES;
		}
		else
		{
			if (ci.selected != status)
			{
				return NSMixedState;
			}
		}
	}
	return status;
}

-(int)selectChildrenExpanded:(int)status
{
	int cnt = 1;
	self.selected = status;
	if (self.expanded)
	{
		for(CIBase * ci in children)
		{
			cnt += [ci selectChildrenExpanded:status];
		}
	}
	
	return cnt;
}

-(void)propagateStatusToChildren:(int)status
{
	if (children)
	{
		for (CIBase * ci in children)
		{
			ci.selected = status;
			[ci propagateStatusToChildren:status];
		}
	}
}

-(void)propagateNewStatusToParent:(int)status
{
    if (parent) {
        NSArray * brothers = [parent getChildren];
        
        for(CIBase * child in brothers)
        {
            if (child.selected != status) {
                status = NSMixedState;
                break;
            }
        }
        
        [parent setSelected:status];
        [parent propagateNewStatusToParent:status];
    }
}

-(BOOL)hasChild
{
    return NO;
}

-(BOOL)canSelect
{
    return NO;
}

-(BOOL)canNavigate
{
    return NO;
}

-(BOOL)hasExpandIcon
{
    return YES;
}

-(NSString *)subtitleText
{
    return @"";
}

-(int)titleLinesCount
{
    return 1;
}

-(NSString *)expandedImageName
{
    return @"cont_text";
}

-(NSString *)collapsedImageName
{
    return @"cont_text";
}

-(UIColor *)titleColor
{
    return [UIColor blackColor];
}

-(UIColor *)subtitleColor
{
    return [UIColor lightGrayColor];
}

-(NSString *)expandOperation
{
    return @"default";
}

#pragma mark -
#pragma mark Drawing Layout

-(CGFloat)calculateHeightForWidth:(CGFloat)width fontBook:(NSDictionary *)fontBook
{
    return CHECK_MARK_AREA_WIDTH;
}

-(int)determineLayout
{
    return DL_CHECK_TEXT;
}

-(void)drawText:(NSString *)text rect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook
{

    //UIImage * greyLine = [skinManager imageForName:@"gray_line"];
    UIImage * image = [skinManager imageForName:@"lite_papyrus"];
    NSString * title = text;
    NSDictionary * attrs = [fontBook valueForKey:self.defaultTextStyle];
    CGRect checkMarkArea;
    
    //
    // drawing check icon
    //
    if (self.iconCheck != nil)
    {
        checkMarkArea = CGRectMake(0, 0, CHECK_MARK_AREA_WIDTH, CHECK_MARK_AREA_WIDTH);
        if (self.drawingPartTouched == DP_CHECK)
        {
            [image drawInRect:checkMarkArea];
        }
        checkMarkArea = CGRectInset(checkMarkArea, AREA_INSET, AREA_INSET);
        [self.iconCheck drawInRect:checkMarkArea];
    }
    
    //
    // drawing text
    //
    CGRect textArea = CGRectMake(CHECK_MARK_AREA_WIDTH, AREA_INSET, rect.size.width - CHECK_MARK_AREA_WIDTH - (self.iconGoto == nil ? 0 : GOTO_MARK_AREA_WIDTH) - (self.iconExpand == nil ? 0 : GOTO_MARK_AREA_WIDTH), rect.size.height - AREA_INSET * 2);
    if (self.drawingPartTouched == DP_TEXT) {
        [image drawInRect:textArea];
    }
    [title drawInRect:textArea withAttributes:attrs];
    
    //
    // drawing goto icon
    //
    if (self.iconGoto != nil)
    {
        checkMarkArea = CGRectMake(rect.size.width - CHECK_MARK_AREA_WIDTH, 0, CHECK_MARK_AREA_WIDTH, CHECK_MARK_AREA_WIDTH);
        if (self.drawingPartTouched == DP_GOTO)
        {
            [image drawInRect:checkMarkArea];
        }
        checkMarkArea = CGRectInset(checkMarkArea, AREA_INSET, AREA_INSET);
        checkMarkArea.size.height = checkMarkArea.size.width/3*4;
        [self.iconGoto drawInRect:checkMarkArea];
    }
    
    //
    // drawing expand icon
    //
    if (self.iconExpand != nil)
    {
        if (self.iconGoto != nil)
        {
            checkMarkArea = CGRectMake(rect.size.width - 2*CHECK_MARK_AREA_WIDTH, 0, CHECK_MARK_AREA_WIDTH, CHECK_MARK_AREA_WIDTH);
        }
        else
        {
            checkMarkArea = CGRectMake(rect.size.width - CHECK_MARK_AREA_WIDTH, 0, CHECK_MARK_AREA_WIDTH, CHECK_MARK_AREA_WIDTH);
        }
        if (self.drawingPartTouched == DP_EXPAND)
        {
            [image drawInRect:checkMarkArea];
        }
        checkMarkArea = CGRectInset(checkMarkArea, AREA_INSET, AREA_INSET);
        checkMarkArea.size.height = checkMarkArea.size.width/3*4;
        [self.iconExpand drawInRect:checkMarkArea];
    }
    
    [self drawBottomLine:skinManager rect:rect];
//    [self drawGradientSeparator:greyLine inRect:rect];
}

-(void)drawRect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook
{
    [self determineIcons:skinManager];
    
}

-(void)drawGradientSeparator:(UIImage *)greyLine inRect:(CGRect)rect
{
    [greyLine drawInRect:CGRectMake(40, rect.size.height-4, rect.size.width-80, 4)];
}

- (void)drawBottomLine:(VBSkinManager *)skinManager rect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (self.lineColor == nil) {
        self.lineColor = [skinManager colorForName:@"lineContent"];
    }
    CGContextSaveGState(ctx);
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    CGContextSetLineWidth(ctx, 1.0);
    /*    CGPoint pts[2];
     pts[0] = CGPointMake(0, rect.size.height - 1);
     pts[1] = CGPointMake(100, 100);
     CGContextStrokeLineSegments(ctx, pts, 2);*/
    CGContextMoveToPoint(ctx, 0, rect.size.height-1);
    CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height-1);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
}

- (void)releaseIconsForLayout:(int)layout
{
    self.drawingLayout = layout;

    if (layout == DL_CHECK_TEXT_EXPAND_GOTO)
    {
    }
    else if (layout == DL_CHECK_TEXT_EXPAND)
    {
        self.iconGoto = nil;
    }
    else if (layout == DL_CHECK_TEXT_GOTO)
    {
        self.iconExpand = nil;
    }
    else if (layout == DL_CHECK_TEXT)
    {
        self.iconGoto = nil;
        self.iconExpand = nil;
    }
    else
    {
        self.iconCheck = nil;
        self.iconGoto = nil;
        self.iconExpand = nil;
    }
}

-(CGFloat)calculateHeightForText:(NSString *)text
                            font:(UIFont *)font width:(CGFloat)width
{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width,120)
                                          options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:font}
                                          context:nil];
    
    return MAX(rect.size.height + 2*AREA_INSET, GOTO_MARK_AREA_WIDTH * 4 / 3);
}

-(CGFloat)correctWidth:(CGFloat)width forLayout:(int)layout
{
    if (layout == DL_CHECK_TEXT)
        return width - CHECK_MARK_AREA_WIDTH;
    if (layout == DL_CHECK_TEXT_EXPAND
        || layout == DL_CHECK_TEXT_GOTO)
        return width - CHECK_MARK_AREA_WIDTH - GOTO_MARK_AREA_WIDTH;
    if (layout == DL_CHECK_TEXT_EXPAND_GOTO)
        return width - CHECK_MARK_AREA_WIDTH - 2*GOTO_MARK_AREA_WIDTH;
    return width;
}

-(void)determineIcons:(VBSkinManager *)skinManager
{
}

-(UIColor *)backgroundColor:(VBSkinManager *)skinManager
{
    return [skinManager colorForName:@"bodyBackground"];
}

-(NSString *)getActionAtPoint:(CGPoint)pt
{
    return nil;
}

-(CGRect)getTouchRectAtPoint:(CGPoint)pt
{
    return CGRectNull;
}

-(NSDictionary *)createParaFormatingWithFont:(UIFont *)font align:(int)align color:(UIColor *)color
{
    NSMutableParagraphStyle *paragraphRef = [NSMutableParagraphStyle new];
    switch(align)
    {
        case 1:
            paragraphRef.alignment = NSTextAlignmentLeft;
            break;
        case 2:
            paragraphRef.alignment = NSTextAlignmentCenter;
            break;
        case 3:
            paragraphRef.alignment = NSTextAlignmentRight;
            break;
        case 4:
            paragraphRef.alignment = NSTextAlignmentJustified;
            break;
        default:
            paragraphRef.alignment = NSTextAlignmentNatural;
            break;
    }
    
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName, font, NSFontAttributeName, paragraphRef, NSParagraphStyleAttributeName,nil];
    
    return dict;
}

@end
