//
//  VBLayoutManager.m
//  VedabaseB
//
//  Created by Peter Kollath on 14/07/14.
//
//

#import "VBSkinManager.h"
#import "VBMainServant.h"
#import "VBStylistArchive.h"
#import "FDTextFormat.h"

@implementation VBSkinManager


-(void)initializeManager
{
    [self checkLayouts];
}

-(void)checkLayouts
{
    if (self.listInitialized)
        return;
    
    NSArray * startFiles;
    
    startFiles = [self enumerateLayoutFiles];
    if ([startFiles count] > 0)
    {
        NSString * fileName = [startFiles objectAtIndex:0];
        NSURL * url = [NSURL fileURLWithPath:fileName];
        NSData * data = [NSData dataWithContentsOfURL:url];
        [self.g_stylist loadData:data];
        
        [self createAlternateStyles];
    }
    
    self.listInitialized = YES;
}


-(void)createAlternateStyles
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    NSEnumerator * E = [self.g_stylist.styles keyEnumerator];
    NSString * key;
    NSString * prop;
    
    while((key = [E nextObject]) != nil)
    {
        FDTextFormat * tf = [[FDTextFormat alloc] init];
        NSDictionary * ds = [self.g_stylist.styles objectForKey:key];
        NSEnumerator * P = [ds keyEnumerator];
        while((prop = [P nextObject]) != nil)
        {
            [tf setHtmlProperty:prop value:[ds objectForKey:prop]];
        }
        [dict setObject:tf forKey:key];
    }

    [VBFolioStorage setAlternateStylesMap:dict];
}

-(NSArray *)enumerateLayoutFiles
{
	NSFileManager * fm = [NSFileManager defaultManager];
	NSString * startDir = [self.fileManager documentsDirectory];
	
	NSError * error = nil;
	NSArray * cont = [fm contentsOfDirectoryAtPath:startDir error:&error];
	
	if (cont == nil)
		return nil;
    
	NSMutableArray * arr = [[NSMutableArray alloc] initWithCapacity:[cont count]];
	for (NSString * strFile in cont)
	{
		if ([strFile hasSuffix:@".vbstylist"])//[fm fileExistsAtPath:testDir isDirectory:&idir])
		{
            NSString * str = [startDir stringByAppendingPathComponent:strFile];
            [arr addObject:str];
        }
    }
    
    if ([arr count] == 0)
    {
        NSString * fileDefault = [[NSBundle mainBundle] pathForResource:@"Untitled" ofType:@"vbstylist"];
        if (fileDefault) {
            [arr addObject:fileDefault];
        }
    }
	
	return arr;
}

-(UIImage *)imageForName:(NSString *)strName
{
    // checks for layout definition
//    [[VBMainServant instance].layoutManager initializeManager];
    return (UIImage *)[self.g_stylist imageForName:strName];
}

-(NSData *)imageDataForName:(NSString *)strName
{
    // checks for layout definition
    //[[VBMainServant instance] checkLayouts];
    return (NSData *)[self.g_stylist imageDataForName:strName];
}

-(NSData *)textForName:(NSString *)strName
{
    // checks for layout definition
    //[[VBMainServant instance] checkLayouts];
    return (NSData *)[self.g_stylist textForName:strName];
}

-(UIColor *)colorForName:(NSString *)strName
{
    if (self.g_colorist == nil)
        self.g_colorist = [[NSMutableDictionary alloc] init];
    
    UIColor * clr = (UIColor *)[self.g_colorist objectForKey:strName];
    if (clr == nil)
    {
        clr = [self.g_stylist colorForName:strName];
        
        if (clr == nil)
            clr = [UIColor colorWithPatternImage:[self imageForName:strName]];
        [self.g_colorist setObject:clr forKey:strName];
    }
    
    return clr;
}

-(UIImage *)endlessTextViewBackgroundImage
{
    return [self imageForName:@"background_yellow"];
}

-(UIImage *)endlessTextViewRecordNoteImage
{
    return [self imageForName:@"note_icon"];
}

-(UIImage *)endlessTextViewBookmarkImage
{
    return [self imageForName:@"cont_bkmk_open"];
}

@end
