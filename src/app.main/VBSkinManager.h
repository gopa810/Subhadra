//
//  VBLayoutManager.h
//  VedabaseB
//
//  Created by Peter Kollath on 14/07/14.
//
//

#import <Foundation/Foundation.h>
#import "VBStylistArchive.h"
#import "EndlessTextViewSkinDelegate.h"

@class VBMainServant;
@class VBFileManager;

@interface VBSkinManager : NSObject <EndlessTextViewSkinDelegate>

@property (weak) IBOutlet VBFileManager * fileManager;
@property (nonatomic,retain) IBOutlet VBMainServant * mainServant;
@property (nonatomic,retain) IBOutlet VBStylistArchive * g_stylist;
@property (nonatomic,retain) NSMutableDictionary * g_colorist;
@property (assign) BOOL listInitialized;

-(void)initializeManager;


-(UIImage *)imageForName:(NSString *)strName;
-(NSData *)textForName:(NSString *)strName;
-(NSData *)imageDataForName:(NSString *)strName;
-(UIColor *)colorForName:(NSString *)strName;


@end
