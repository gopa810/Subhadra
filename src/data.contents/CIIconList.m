//
//  ContentItemIconList.m
//  VedabaseB
//
//  Created by Peter Kollath on 21/07/16.
//
//

#import "CIIconList.h"
#import "Canvas.h"
#import "CIIconListItem.h"
#import "VBMainServant.h"

@implementation CIIconList



-(id)init
{
    self = [super init];
    if (self)
    {
        self.items = [NSMutableArray new];
        self.fontSizeIndex = 3;
        self.iconSizeIndex = 3;
        self.iconAlign = 2;
        self.iconSpacing = 12.0f;
    }
    
    return self;
}


#pragma mark -
#pragma mark Drawing Layout

-(CGFloat)calculateHeightForWidth:(CGFloat)width fontBook:(NSDictionary *)fontBook
{
    // determine icon size in pixels
    float iconSize;
    switch(self.iconSizeIndex)
    {
        case 1: iconSize = 64.0f; break;
        case 2: iconSize = 56.0f; break;
        case 3: iconSize = 48.0f; break;
        case 4: iconSize = 40.0f; break;
        default: iconSize = 32.0f; break;
    }
    
    // determine font
    if (self.fontSizeIndex < 1 || self.fontSizeIndex > 5)
        self.fontSizeIndex = 3;
    UIFont * font = [fontBook objectForKey:[NSString stringWithFormat:@"fontR%d", self.fontSizeIndex]];
    
    UIColor * color = [VBMainServant colorForName:@"darkTextColor"];
    
    NSMutableParagraphStyle *paragraphRef = [NSMutableParagraphStyle new];
    paragraphRef.alignment = NSTextAlignmentCenter;
    
    self.paraFormat = [NSDictionary dictionaryWithObjectsAndKeys:color, NSForegroundColorAttributeName, font, NSFontAttributeName, paragraphRef, NSParagraphStyleAttributeName,nil];
    
    
    for (CIIconListItem * item in self.items) {
        
        item.textSize = [item.name sizeWithAttributes:self.paraFormat];
        item.usedRect = CGRectMake(0, 0, MAX(item.textSize.width, iconSize), iconSize + self.iconSpacing/2 + item.textSize.height);
    }
    
    CGFloat ypos = self.paddingTop;
    CGFloat xpos = self.paddingLeft;
    CGFloat rightLimit = width - self.paddingRight;
    
    NSMutableArray * lineItems = [NSMutableArray new];
    
    for (CIIconListItem * item in self.items) {
        if (item.usedRect.size.width + self.iconSpacing + xpos > rightLimit)
        {
            [self alignItems:lineItems width:width];
            ypos += [self getMaxItemHeight:lineItems];
            ypos += self.iconSpacing;
            xpos = self.paddingLeft;
            [lineItems removeAllObjects];
        }
        
        item.usedRect = CGRectMake(xpos, ypos, item.usedRect.size.width, item.usedRect.size.height);
        [lineItems addObject:item];
    }
    
    [self alignItems:lineItems width:width];
    ypos += [self getMaxItemHeight:lineItems];
    ypos += self.paddingBottom;
    [lineItems removeAllObjects];
    
    return ypos;
}

-(void)alignItems:(NSArray *)lineItems width:(CGFloat)width
{
    CGFloat spaceWidth;
    CGFloat xpos;
    CGFloat step;
    CGFloat totalWidth = 0;
    for(CIIconListItem * item in lineItems)
    {
        totalWidth += item.usedRect.size.width;
    }
    
    
    if (self.iconAlign == 2)
    {
        totalWidth += lineItems.count * self.iconSpacing;
        spaceWidth = (width - self.paddingLeft - self.paddingRight - totalWidth) / 2;
        xpos = self.paddingLeft + spaceWidth;
        step = self.iconSpacing;
    }
    else if (self.iconAlign == 3)
    {
        totalWidth += lineItems.count * self.iconSpacing;
        spaceWidth = (width - self.paddingLeft - self.paddingRight - totalWidth);
        xpos = self.paddingLeft + spaceWidth;
        step = self.iconSpacing;
    }
    else if (self.iconAlign == 4)
    {
        spaceWidth = (width - self.paddingLeft - self.paddingRight - totalWidth) / lineItems.count;
        xpos = self.paddingLeft;
        step = spaceWidth;
    }
    else
    {
        xpos = self.paddingLeft;
        step = self.iconSpacing;
    }
    
    for (CIIconListItem * item in lineItems)
    {
        item.usedRect = CGRectMake(xpos, item.usedRect.origin.y,
                                   item.usedRect.size.width, item.usedRect.size.height);
        xpos += item.usedRect.size.width + step;
    }
    
}

-(CGFloat)getMaxItemHeight:(NSArray *)lineItems
{
    CGFloat max = 0;
    for (CIIconListItem * item in lineItems)
    {
        max = MAX(item.usedRect.size.height, max);
    }

    return max;
}

-(int)determineLayout
{
    return DL_ALL_TEXT;
}

-(void)drawRect:(CGRect)rect skinManager:(VBSkinManager *)skinManager fontBook:(NSDictionary *)fontBook
{
    
    // determine icon size in pixels
    float iconSize;
    switch(self.iconSizeIndex)
    {
        case 1: iconSize = 64.0f; break;
        case 2: iconSize = 56.0f; break;
        case 3: iconSize = 48.0f; break;
        case 4: iconSize = 40.0f; break;
        default: iconSize = 32.0f; break;
    }
    
    for (CIIconListItem * item in self.items)
    {
        CGRect imageRect = CGRectMake(item.usedRect.origin.x + item.usedRect.size.width/2 - iconSize/2, item.usedRect.origin.y, iconSize, iconSize);
        CGRect textRect = CGRectMake(item.usedRect.origin.x, item.usedRect.origin.y + item.usedRect.size.height - item.textSize.height, item.usedRect.size.width, item.textSize.height );
        
        if (item.image == nil)
            item.image = [skinManager imageForName:item.imageName];
        if (item.image != nil)
            [item.image drawInRect:imageRect];
        [item.name drawInRect:textRect
               withAttributes:self.paraFormat];
    }
    
}

-(void)addImage:(NSString *)imageName itemName:(NSString *)text action:(NSString *)actionText
{
    CIIconListItem * item = [CIIconListItem new];
    
    item.name = text;
    item.imageName = imageName;
    item.actionText = actionText;
    
    [self.items addObject:item];
}

-(NSString *)getActionAtPoint:(CGPoint)pt
{
    for (CIIconListItem * item in self.items)
    {
        if (CGRectContainsPoint(item.usedRect, pt))
            return item.actionText;
    }
    return nil;
}

-(CGRect)getTouchRectAtPoint:(CGPoint)pt
{
    for (CIIconListItem * item in self.items)
    {
        if (CGRectContainsPoint(item.usedRect, pt))
            return item.usedRect;
    }
    return [super getTouchRectAtPoint:pt];
}

@end
