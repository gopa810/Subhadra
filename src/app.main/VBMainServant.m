//
//  VedabaseBAppDelegate.m
//  VedabaseB
//
//  Created by Peter Kollath on 1/21/11.
//  Copyright GPSL 2011. All rights reserved.
//

#import "VBMainServant.h"
#import "VCText.h"
#import "VCHits2.h"
#import "Constants.h"
#import "ContentTableController.h"
#import "FlatFileUtils.h"
#import "VBStylistArchive.h"
#import "ContentPageController.h"
#import "VedabaseURLProtocol.h"
#import "TGTabController.h"
#import "VBFileManager.h"
#import "VBContentManager.h"
#import "VBFolio.h"
#import "EndlessScrollView.h"

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif


/*
 *   #if (TARGET_IPHONE_SIMULATOR)
 *   #endif
 *   #if (TARGET_OS_IPHONE)
 *   #endif
 */

@implementation VBMainServant

@synthesize window;
@synthesize currentFolio;
@synthesize dictionaryToRemove;
@synthesize player;
@synthesize buildDate;


NSString * g_docDir = nil;
NSString * g_tmpDir = nil;

#pragma mark -
#pragma mark Application lifecycle

-(id)init
{
    self = [super init];
    if (self) {
        
        //NSLog(@"LISTSTATUS = %d in VBMainServant-init", self.storageRemoteListStatus);

        //self.storageRemoteListStatus = LISTSTATUS_UNINIT;
        
        //self.folioList = [[NSMutableArray alloc] init];
        self.buildDate = [NSString stringWithUTF8String:__DATE__];
        self.templates = [[NSMutableArray alloc] init];

        NSLog(@"--app point 1--");
        
    }
    return self;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler
{

    self.backgroundSessionCompletionHandler = completionHandler;
    
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [NSURLProtocol registerClass:[VedabaseURLProtocol class]];
    
    //NSLog(@"--app point 2--");
    
    UIScreen * screen = [UIScreen mainScreen];
    CGSize screenSize = screen.bounds.size;
    CGFloat widthPortait = MIN(screenSize.width, screenSize.height);
    CGFloat widthLandscape = MAX(screenSize.width, screenSize.height);
    NSUserDefaults * userDef = [NSUserDefaults standardUserDefaults];
    int contTextSizeDefault = ((widthPortait < 330) ? 1 : (widthPortait < 700 ? 2 : 3));

    NSDictionary * appSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:NO], @"text_eth_expanded",
                                  @1, @"cs_item_action",
                                  [NSNumber numberWithBool:NO], kASStoreAvailable,
                                  [NSNumber numberWithBool:NO], kASLocalCopyAllowed,
                                  @1, @"cont_bkmk_pos",
                                  @1, @"cont_note_pos",
                                  @1, @"cont_highs_pos",
                                  [NSNumber numberWithDouble:widthPortait/12.0], @"EndlessMargins",
                                  [NSNumber numberWithDouble:widthLandscape/12.0], @"EndlessMarginsLandscape",
                                  [NSNumber numberWithDouble:widthPortait/96.0], @"paddingStepSize",
                                  [NSNumber numberWithDouble:((widthPortait - 320) / 896)], @"FDCharFormat_multiplyFontSize",
                                  @3, @"cs_goto_icon",
                                  @1, @"cs_expand_icon",
                                  @-1, @"cs_swipeleft_action",
                                  @-1, @"cs_swiperight_action",
                                  @1, @"ts_swipelr_action",
                                  @3, @"ts_swiperl_action",
                                  @1, @"cont_play_pos",
                                  @1, @"cont_view_pos",
                                  @NO, @"default_bookmarks_init",
                                  @100, @"ts_bit",
                                  @100, @"ts_pudit",
                                  [NSNumber numberWithInt:contTextSizeDefault], @"cont_text_size",
                                  nil];
    
    [userDef registerDefaults:appSettings];
    [userDef synchronize];

    //[userDef setInteger:1 forKey:@"cs_expand_icon"];
    //[userDef setInteger:1 forKey:@"cont_text_size"];
    //[userDef setInteger:3 forKey:@"cont_bkmk_pos"];
    
    // Add the tab bar controller's current view as a subview of the window
    //[window addSubview:tabBarController.view];
    //tabBarController.view.hidden = YES;
    [window makeKeyAndVisible];

    //popupDialogOpen = NO;
    //mainTextJavaScript = nil;
	self.player = nil;
    //self.needLoadContent = YES;
    //self.phrases = [[VBHighlightedPhraseSet alloc] init];
    
    [self.skinManager initializeManager];

    [self.userInterfaceManager createUserInterface];


    // regfister for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationReceived:)
                                                 name:kCommandOpenFolio
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationReceived:)
                                                 name:kNotifyCollectionsListChanged
                                               object:nil];
    // app start notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyApplicationStart
                                                        object:self userInfo:nil];

    
    [self initSearchTemplates];
    
    //[[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"vedabase.prabhupada.books"];
    //[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"last-update-folio.ivc"];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [self.currentFolio saveShadow];
    [self.userInterfaceManager saveUIState];
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    [ud synchronize];
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.userInterfaceManager start];
    
    if (self.currentFolio == nil) {
        NSString *fileName = [self.fileManager databasePath];
        if (fileName) {
            [self openFolioFile:fileName];
        }
    }
}

//
// we should omit the first going to foreground
// since our folio DB may not be loaded yet
// so we will let first invokation of restoring text position
// on folio loader callback
//
-(void)applicationWillEnterForeground:(UIApplication *)application
{
    [self.userInterfaceManager stop];
    
    if (self.firstForegroundVisible)
    {
        [self.userInterfaceManager restoreUIState];
    }
    self.firstForegroundVisible = YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    //
    // Called when the application is about to terminate.
    //
    [NSURLProtocol unregisterClass:[VedabaseURLProtocol class]];
     
    [self.currentFolio saveShadow];
    
	self.currentFolio = nil;
    self.templates = nil;
    
}


-(void)initSearchTemplates
{
    NSString * stPath = [[NSBundle mainBundle] pathForResource:@"search_templates" ofType:@"txt"];
    NSString * templates = [NSString stringWithContentsOfFile:stPath encoding:NSUTF8StringEncoding error:NULL];
    NSArray * lines = [templates componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSString * tempName = nil;
    for (NSString * s in lines)
    {
        if (tempName == nil)
        {
            tempName = s;
        }
        else
        {
            VBQueryTemplate * template = [[VBQueryTemplate alloc] init];
            template.templateName = tempName;
            template.templateString = s;
            tempName = nil;
            [self.templates addObject:template];
            //[template release];
        }
    }
}

-(void)notificationReceived:(NSNotification *)note
{
}



+(void)logRect:(CGRect)rect1 name:(NSString *)sName
{
    NSLog(@"[%@ rect]\n%f, %f, %f, %f", sName, rect1.origin.x, rect1.origin.y, rect1.size.width, rect1.size.height);
}

-(CGRect)applicationFrame
{
    return self.userInterfaceManager.view.frame;
    
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    CGRect status = [[UIApplication sharedApplication] statusBarFrame];
    CGRect mainView = window.rootViewController.view.frame;
    UIDeviceOrientation ori = [[UIDevice currentDevice] orientation];
    
    //CGRect mainViewRect = self.window.frame;
    
    
    CGRect retVal;
    [VBMainServant logRect:status name:@"status"];
    [VBMainServant logRect:mainBounds name:@"main"];
    [VBMainServant logRect:mainView name:@"mainView"];
    
    
    if (status.origin.x == 0)
    {
        if (status.origin.y == 0)
        {
            if (status.size.width > status.size.height)
            {
                retVal = CGRectMake(mainBounds.origin.x, mainBounds.origin.y + status.size.height,
                                    mainBounds.size.width, mainBounds.size.height - status.size.height);
            }
            else
            {
                retVal = CGRectMake(mainBounds.origin.x + status.size.width, mainBounds.origin.y,
                                    mainBounds.size.width - status.size.width, mainBounds.size.height);
            }
        }
        else
        {
            retVal = CGRectMake(mainBounds.origin.x, mainBounds.origin.y,
                                mainBounds.size.width, mainBounds.size.height - status.size.height);
        }
    }
    else
    {
        if (status.origin.y == 0)
        {
            retVal = CGRectMake(mainBounds.origin.x, mainBounds.origin.y,
                                mainBounds.size.width - status.size.width, mainBounds.size.height);
        }
    }
    
  
    if (UIDeviceOrientationIsLandscape(ori)) {
        retVal = CGRectMake(retVal.origin.y, mainBounds.size.width - retVal.size.width,
                            retVal.size.height, retVal.size.width);
    }
    
    
    [VBMainServant logRect:retVal name:@"retval"];
    return retVal;
}


+(VBMainServant *)instance
{
    return (VBMainServant *)[[UIApplication sharedApplication] delegate];
}

+(UIWindow *)mainWindow
{
    return [[VBMainServant instance] window];
}

+(VBFolio *)folio
{
    return [[VBMainServant instance] currentFolio];
}


#pragma mark -
#pragma mark File Lists





/*-(void)makeCustomizedTabBar
{
    UITabBarItem * tabBarItem = nil;    
    
    self.currentStoreController = [[[StoreViewController alloc] initWithNibName:@"StoreViewController" bundle:nil] autorelease];
    
    tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Store" 
                                               image:[VBMainServant imageForName:@"tab_store"]
                                                 tag:0];
    //[tabBarItem setFinishedSelectedImage:[VBMainServant imageForName:@"tab_store"] withFinishedUnselectedImage:[VBMainServant imageForName:@"tab_store_dis"]];
    self.currentStoreController.tabBarItem = tabBarItem;
    [tabBarItem release];
    
    [self.tabBarController setViewControllers:[self.tabBarController.viewControllers arrayByAddingObject:self.currentStoreController]];
    //[self.tabBarController addChildViewController:self.currentStoreController];
}*/

/*-(void)applyStylistLayout:(VBStylistArchive *)stylist
{
    g_stylist = stylist;
    [g_colorist removeAllObjects];

    if (self.tabBarController) {
        [tabBarController.tabBar setBackgroundImage:[VBMainServant imageForName:@"foot1"]];
    }
    
    
    [(UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:0] setFinishedSelectedImage:[VBMainServant imageForName:@"tab_cont"] withFinishedUnselectedImage:[VBMainServant imageForName:@"tab_cont_ua"]];
    [(UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:1] setFinishedSelectedImage:[VBMainServant imageForName:@"tab_text"] withFinishedUnselectedImage:[VBMainServant imageForName:@"tab_text_ua"]];
    [(UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:2] setFinishedSelectedImage:[VBMainServant imageForName:@"tab_search"] withFinishedUnselectedImage:[VBMainServant imageForName:@"tab_search_ua"]];
    [(UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:3] setFinishedSelectedImage:[VBMainServant imageForName:@"tab_store"] withFinishedUnselectedImage:[VBMainServant imageForName:@"tab_store_dis"]];
    
    NSDictionary * dictTabProps = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], UITextAttributeTextColor, nil];
    
    for (UITabBarItem * item in self.tabBarController.tabBar.items)
    {
        [item setTitleTextAttributes:dictTabProps forState:UIControlStateNormal];
    }


    
    NSDictionary * dictTabProps2 = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor brownColor], UITextAttributeTextColor, nil];
    
    for (UITabBarItem * item in self.tabBarController.tabBar.items)
    {
        [item setTitleTextAttributes:dictTabProps2 forState:UIControlStateSelected];
    }


}*/

-(void)openFolioFile:(NSString *)fileName
{
	self.currentFolio = [[VBFolio alloc] initWithFileName:fileName];
    self.currentFolio.documentsDirectory = [self.fileManager documentsDirectory];
    [self.currentFolio loadShadow];
    
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.currentFolio, @"folio", self.currentFolio.info, @"dictionary", nil];
    
    //NSLog(@"--before sending notification");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyFolioOpen
                                                        object:self userInfo:userInfo];
    
    
    if (self.userInterfaceManager.folioSource)
    {
        self.userInterfaceManager.folioSource.folio = self.currentFolio;
        [self.userInterfaceManager.textView2 restoreTextPosition];
    }
    
    [self.contentManager setFolio:self.currentFolio];
}


#pragma mark -
#pragma mark SENDING NOTIFICATIONS

-(void)sendNotificationWithName:(NSString *)noteString
{
    [[NSNotificationCenter defaultCenter] postNotificationName:noteString
                                                        object:self
                                                      userInfo:nil];
}

-(void)sendNotification:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] postNotification:note];
}


-(void)sendNotificationAsync:(NSString *)noteString
{
    [self performSelectorOnMainThread:@selector(sendNotificationWithName:)
                           withObject:noteString
                        waitUntilDone:NO];
}


-(void)sendNotificationAsync:(NSString *)noteString objectName:(NSString *)aName object:(id)anObject
{
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:anObject, aName, nil];
    NSNotification * note = [NSNotification notificationWithName:noteString
                                                          object:self
                                                        userInfo:userInfo];
    [self performSelectorOnMainThread:@selector(sendNotification:)
                           withObject:note
                        waitUntilDone:NO];
}

#pragma mark -
#pragma mark list of remote storage files

-(void)logArray:(NSArray *)array withTitle:(NSString *)title
{
    NSLog(@"==================================");
    NSLog(@"Title: %@", title);
    NSLog(@"==================================");
    

    
    NSLog(@"==================================");
}




#pragma mark -
#pragma mark application delegate


+(NSURL *)fakeURL
{
    NSString * docDir = [[VBMainServant instance].fileManager documentsDirectory];
	NSString * fileTemp = [docDir stringByAppendingPathComponent:@"temp01.html"];
    return [NSURL fileURLWithPath:fileTemp];
}

-(TGTabController *)tabController
{
    return (TGTabController *)self.window.rootViewController;
}



-(void)performTextScript:(NSString *)script
{
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:script, @"script", nil];
    NSNotification * note = [NSNotification notificationWithName:kNotifyCmdOpenUrl object:self userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] performSelector:@selector(postNotification:) withObject:note afterDelay:0.1];
    
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
 // Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
 */

/*
 // Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
 */


/*-(ContentItemModel *)currentFolioContent
{
	//VCContent * contBar = (VCContent * )[[tabBarController viewControllers] objectAtIndex:0];
	//TO DO: func
	return [(ContentTableController *)self.currentContentView folioContent];
}*/


#pragma mark -
#pragma mark Sound Management

-(void)runSound:(NSData *)data
{
    if (self.player != nil)
    {
        [self.player stop];
    }
    
    AVAudioPlayer * new_player = [[AVAudioPlayer alloc] initWithData:data error:NULL];
    self.player = new_player;
    //[new_player release];
    
    //[self.player prepareToPlay];
    [self.player setDelegate:self];
    if ([self.player play] == NO)
        NSLog(@"unsuccess");
}

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player
                        successfully: (BOOL) completed 
{
    if (completed == YES) {
        self.player = nil;
    }
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    NSLog(@"received memory warning...");
    
    self.currentFolio = nil;
    [self.userInterfaceManager setFolioSource:nil];
}


+(NSString*)base64forData:(NSData*)theData 
{
    
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

#pragma mark -
#pragma mark Static Images



+(NSURL *)onlineStoreURL
{
#if (TARGET_IPHONE_SIMULATOR)
    return [NSURL fileURLWithPath:@"/Library/Application Support/iPadFolio5"];
#else
    return [NSURL URLWithString:@"http://gopal.home.sk/data"];
#endif
}



BOOL g_isIpadInitialized = NO;
BOOL g_isIpad = NO;

+(BOOL)isIPAD
{
    if (!g_isIpadInitialized)
    {
        g_isIpad = ([(NSString *)[UIDevice currentDevice].model isEqualToString:@"iPad"]);
        g_isIpadInitialized = YES;
    }
    
    return g_isIpad;
}


-(void)showDialog:(UIViewController *)controller
{
    [self.userInterfaceManager insertViewController:controller withDiff:-40];
    /*TGTabController * mainController = (TGTabController *)window.rootViewController;
    [mainController.view addSubview:controller.view];
    
    [mainController.subControllers addObject:controller];
    
    controller.view.frame = [self applicationFrame];
    */
}

-(void)removeControllerFromSubs:(UIViewController *)controller
{
    [self.userInterfaceManager removeViewController:controller withDiff:-40 name:@""];
    /*
    TGTabController * mainController = (TGTabController *)window.rootViewController;
    
    [mainController.subControllers removeObject:controller];
    */
}

+(VBUserInterfaceManager *)userInterfaceManager
{
    return [VBMainServant instance].userInterfaceManager;
}

+(VBSkinManager *)skinManager
{
    return [VBMainServant instance].skinManager;
}

+(UIImage *)imageForName:(NSString *)strName
{
    return [[VBMainServant instance].skinManager imageForName:strName];
}

+(NSData *)imageDataForName:(NSString *)strName
{
    return [[VBMainServant instance].skinManager imageDataForName:strName];
}

+(NSData *)textForName:(NSString *)strName
{
    return [[VBMainServant instance].skinManager textForName:strName];
}

+(UIColor *)colorForName:(NSString *)strName
{
    return [[VBMainServant instance].skinManager colorForName:strName];
}

@end














