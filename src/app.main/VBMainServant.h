//
//  VedabaseBAppDelegate.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/21/11.
//  Copyright GPSL 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBFolio.h"
#import <AVFoundation/AVFoundation.h>

#import "TGTabController.h"
#import "VBUserInterfaceManager.h"
#import "VBSkinManager.h"
#import "VBFileManager.h"
#import <StoreKit/StoreKit.h>
#import "Constants.h"
#import "FDDrawingProperties.h"

@class InitialDownloadViewController;
@class VBProductManager, VBContentManager;

@interface VBMainServant : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UIActionSheetDelegate, AVAudioPlayerDelegate> {


}

@property BOOL needLoadContent;

@property (strong) InitialDownloadViewController * downloadViewController;
@property (weak) IBOutlet VBUserInterfaceManager * userInterfaceManager;
@property (weak) IBOutlet VBSkinManager * skinManager;
@property (weak) IBOutlet VBFileManager * fileManager;
@property (weak) IBOutlet VBProductManager * productManager;
@property IBOutlet VBContentManager * contentManager;
@property IBOutlet FDDrawingProperties * drawer;
@property BOOL firstForegroundVisible;

@property (nonatomic) IBOutlet UIWindow *window;

@property VBFolio * currentFolio;
@property NSDictionary * dictionaryToRemove;

@property NSInteger storeTabItemTag;

@property (nonatomic,retain) AVAudioPlayer * player;
@property (assign, readonly) TGTabController * tabController;
@property (copy) NSString * buildDate;

@property (nonatomic, retain) NSMutableArray * templates;

@property (copy) void (^backgroundSessionCompletionHandler)(void);

// only instance of this
+(VBMainServant *)instance;
// directory where folios and data files are stored
//+(NSString *)documentsDirectory;
+(NSURL *)onlineStoreURL;
// current folio
+(VBFolio *)folio;
+(UIWindow *)mainWindow;
+(VBSkinManager *)skinManager;
+(VBUserInterfaceManager *)userInterfaceManager;

//
//-(void)requestRemoteStorageList;

+(NSURL *)fakeURL;


-(void)openFolioFile:(NSString *)dict;
-(void)runSound:(NSData *)data;


+(NSString*)base64forData:(NSData*)theData;
-(void)performTextScript:(NSString *)script;
-(CGRect)applicationFrame;
-(void)showDialog:(UIViewController *)controller;
-(void)removeControllerFromSubs:(UIViewController *)controller;

+(BOOL)isIPAD;
+(UIImage *)imageForName:(NSString *)strName;
+(NSData *)imageDataForName:(NSString *)strName;
+(UIColor *)colorForName:(NSString *)strName;
+(NSData *)textForName:(NSString *)strName;


@end

