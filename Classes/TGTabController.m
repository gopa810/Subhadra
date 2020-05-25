//
//  TGTabController.m
//  MyTabController
//
//  Created by Peter Kollath on 1/12/13.
//  Copyright (c) 2013 Peter Kollath. All rights reserved.
//

#import "TGTabController.h"
#import "VBDimensions.h"

@interface TGTabController ()


@end



@implementation TGTabBarItem

@synthesize noteNumber, titleLabel;

-(id)init
{
    self = [super init];
    if (self) {
        self.noteNumber = 0;
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.noteNumber = 1;
    }
    return self;
}

/*
-(void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 0);
    CGContextSetFillColorWithColor(c, [UIColor redColor].CGColor);
    CGContextAddEllipseInRect(c, CGRectMake(0,0,20,20));
    CGContextStrokePath(c);
    CGContextSetStrokeColorWithColor(c, [UIColor whiteColor].CGColor);
    NSString * s = [NSString stringWithFormat:@"%d", self.noteNumber];
    [s drawInRect:CGRectMake(0,0,20,20)
         withFont:[UIFont systemFontOfSize:18]
    lineBreakMode:UILineBreakModeClip
        alignment:UITextAlignmentCenter];
    
}
*/

@end

@implementation TGTabController


-(id)init
{
    BOOL isIPAD = [(NSString *)[UIDevice currentDevice].model isEqualToString:@"iPad"];
    self = [super init];
    if (self) {
        //self.wantsFullScreenLayout = YES;
        m_heightOfBar = isIPAD ? 75 : 40;
        m_barItemCounter = 1;
        isFullScreen = NO;
        self.barImageHeight = 40;
        self.barTextHeight = 20;
        self.barItemWidth = isIPAD ? 125 : 50;
        self.barTextFont = [UIFont systemFontOfSize:14.0];
        self.barTextColor = [UIColor brownColor];
        self.barInactiveAlpha = 0.5;
        self.highlightStyle = TGTabControllerHighlightStyleBackground;
        self.subControllers = [[NSMutableArray alloc] init];
        
        CGRect mainRect = [self applicationFrame];
        CGRect tabRect = CGRectMake(0, mainRect.size.height - m_heightOfBar,
                                    mainRect.size.width, m_heightOfBar);
        

      
        // main frame (whole screen without status bar)
        UIView * l_mainFrame = [[UIView alloc] initWithFrame:mainRect];
        self.view = l_mainFrame;
        [l_mainFrame setBackgroundColor:[UIColor clearColor]];
        //[l_mainFrame release];
        
        CGRect presentFrame = [self calculateSubviewFrame];
        UIView * vv = nil;
        UIImageView * imgv = nil;

        // under presentation layer
        vv = [[UIView alloc] init];
        self.layerUnderPresentation = vv;
        vv.frame = presentFrame;
        vv.backgroundColor = [UIColor clearColor];
        vv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:vv];
        //[vv release];
        
        // presentation layer
        vv = [[UIView alloc] init];
        self.layerPresentation = vv;
        vv.frame = presentFrame;
        vv.backgroundColor = [UIColor clearColor];
        vv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:vv];
        //[vv release];

        // above presentation layer
        /*vv = [[UIView alloc] init];
        self.layerAbovePresentation = vv;
        vv.frame = presentFrame;
        vv.backgroundColor = [UIColor clearColor];
        vv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:vv];
        [vv release];*/

        // header background view
        imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, presentFrame.size.width, [VBDimensions headerHeight])];
        [self.layerUnderPresentation addSubview:imgv];
        self.headerImageView = imgv;
        imgv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //[imgv release];

        // background for tab bar
        imgv = [[UIImageView alloc] initWithFrame:tabRect];
        imgv.image = nil;
        self.barBackgroundImageView = imgv;
        [self.view addSubview:imgv];
        imgv.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        //[imgv release];

        // container for tab bar items
        UIView * tabii = [[UIView alloc] init];
        self.tabBarItems = tabii;
        //[tabii release];
        tabii.frame = tabRect;
        tabii.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        tabii.backgroundColor = [UIColor clearColor];
        tabii.bounds = CGRectMake(0.0, 0.0, isIPAD ? 60.0 : 55.0, m_heightOfBar);
        [self.view addSubview:tabii];
        
        NSString* imageName = [[NSBundle mainBundle] pathForResource:@"btn_fullscreen" ofType:@"png"];
     
        UIImage * img = [[UIImage alloc] initWithContentsOfFile:imageName];
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 100;
        [btn addTarget:self action:@selector(onTabButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self action:@selector(onTabButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
        [btn addTarget:self action:@selector(onTabButtonReleasedOut:) forControlEvents:UIControlEventTouchUpOutside];
        [btn setImage:img forState:UIControlStateNormal];
        btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        btn.frame = CGRectMake(tabRect.origin.x + tabRect.size.width - 32,
                               tabRect.origin.y + tabRect.size.height - 32,
                               32, 32);//self.tabBarItems.frame;
        btn.hidden = NO;
        self.btnFullScreen = btn;
        [self.view addSubview:btn];


    }
    return self;
}

-(CGRect)applicationFrame
{
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    CGRect status = [[UIApplication sharedApplication] statusBarFrame];
    CGRect retVal;
    //[self logRect:status name:@"status"];
    //[self logRect:mainBounds name:@"main"];
    
    if (status.size.width < status.origin.x)
    {
        retVal = CGRectMake(0.0, 0.0, status.origin.x, mainBounds.size.height);
    }
    else if (status.origin.y > status.size.width)
    {
        retVal = CGRectMake(0.0, 0.0, status.size.width, status.origin.y);
    }
    else if (status.size.width > status.size.height)
    {
        retVal = CGRectMake(0.0, status.size.height, status.size.width,
                          mainBounds.size.height - status.size.height);
    }
    else
    {
        retVal = CGRectMake(status.size.width, 0.0, mainBounds.size.width - status.size.width,
                          status.size.height);
    }
    //[self logRect:retVal name:@"retval"];
    return retVal;
}

-(CGRect)calculateSubviewFrame
{
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    CGRect status = [[UIApplication sharedApplication] statusBarFrame];
    CGRect retVal;
    //[self logRect:status name:@"status"];
    //[self logRect:mainBounds name:@"main"];
    
    
    if (status.size.width < status.origin.x)
    {
        retVal = CGRectMake(0.0, status.size.width,
                            status.origin.x,
                            mainBounds.size.height - status.size.width - m_heightOfBar);
    }
    else if (status.origin.y > status.size.width)
    {
        retVal = CGRectMake(0.0, status.size.height, status.size.width, status.origin.y - m_heightOfBar - status.size.height);
    }
    else if (status.size.width > status.size.height)
    {
        retVal = CGRectMake(0.0, status.size.height, status.size.width,
                            mainBounds.size.height - 2*status.size.height - m_heightOfBar);
    }
    else
    {
        retVal = CGRectMake( 0, status.size.width,
                            mainBounds.size.width - status.size.width,
                            status.size.height - status.size.width - m_heightOfBar);
    }
    //[self logRect:retVal name:@"retval"];
    return retVal;
}


-(void)logRect:(CGRect)mainRect name:(NSString *)strName
{
    NSLog(@"%@ = %f,%f - %f,%f", strName, mainRect.origin.x, mainRect.origin.y,
          mainRect.size.width, mainRect.size.height);
}


-(UIImage *)barBackgroundImage
{
    return [[self barBackgroundImageView] image];
}

-(void)setBarBackgroundImage:(UIImage *)barBackgroundImage
{
    [[self barBackgroundImageView] setImage:barBackgroundImage];
}

-(TGTabBarItem *)findBarItem:(NSInteger)tag
{
    for (UIView * v1 in self.tabBarItems.subviews) {
        if (v1.tag == tag) {
            return (TGTabBarItem *)v1;
        }
    }
    return nil;
}

-(IBAction)onTabButtonPressed:(id)sender
{
    if ([sender isKindOfClass:[UIView class]])
    {
        UIView * btn = (UIView *)sender;
        TGTabBarItem * item = [self findBarItem:btn.tag];
        if (item) {
            item.backgroundColor = [UIColor brownColor];
        }
    }
}

-(IBAction)onTabButtonReleased:(id)sender
{
    if ([sender isKindOfClass:[UIView class]])
    {
        UIView * btn = (UIView *)sender;
        TGTabBarItem * item = [self findBarItem:btn.tag];
        if (item) {
            item.backgroundColor = [UIColor clearColor];
            [self selectBarItemWithTag:item.tag direction:TGTabItemTransitionDefault];
        } else if (btn.tag == 100) {
            [self toogleFullScreen];
        }
    }
}

-(IBAction)onTabButtonReleasedOut:(id)sender
{
    if ([sender isKindOfClass:[UIView class]])
    {
        UIView * btn = (UIView *)sender;
        TGTabBarItem * item = [self findBarItem:btn.tag];
        if (item) {
            item.backgroundColor = [UIColor clearColor];
        }
    }
}

-(void)executeTouchCommand:(NSString *)command data:(NSDictionary *)aData
{
}

-(void)activateBarItem:(TGTabBarItem *)item highlighted:(BOOL)bState
{
    if (self.highlightStyle == TGTabControllerHighlightStyleAlpha) {
        if (bState) {
            item.alpha = 1.0;
        } else {
            item.alpha = self.barInactiveAlpha;
        }
    } else if (self.highlightStyle == TGTabControllerHighlightStyleBackground) {
        if (bState) {
            item.backgroundImageView.hidden = NO;
        } else {
            item.backgroundImageView.hidden = YES;
        }
    }
}

-(void)selectBarItemWithTag:(NSInteger)tag direction:(NSInteger)dir
{
    TGTabBarItem * newItem = [self findBarItem:tag];
    UIViewController * newController = [newItem subViewController];
    
    if (self.selectedTab == newItem)
        return;
    
    if (self.selectedTab == nil && newController != nil)
    {
        [self activateBarItem:newItem highlighted:YES];
        //newController.view.frame = [self subviewControllerFrame];
        [newController viewWillAppear:YES];
        newController.view.hidden = NO;
        [newController viewDidAppear:YES];
    }
    else if (self.selectedTab != nil && newController == nil)
    {
        [self.selectedTab.subViewController viewWillDisappear:YES];
        self.selectedTab.subViewController.view.hidden = YES;
        [self.selectedTab.subViewController viewDidDisappear:YES];
    }
    else if (self.selectedTab != nil && newController != nil)
    {
        CGRect rect1 = self.selectedTab.subViewController.view.frame;
        CGRect rectRight = CGRectMake(rect1.origin.x + rect1.size.width, rect1.origin.y, rect1.size.width, rect1.size.height);
        CGRect rectLeft = CGRectMake(rect1.origin.x - rect1.size.width, rect1.origin.y, rect1.size.width, rect1.size.height);
        
        CGRect rectPrepared;
        CGRect rectTrash;
        
        if ((dir == TGTabItemTransitionRightToLeft || self.selectedTab.tag < tag)
            && dir != TGTabItemTransitionLeftToRight)
        {
            rectPrepared = rectRight;
            rectTrash = rectLeft;
        }
        else
        {
            rectPrepared = rectLeft;
            rectTrash = rectRight;
        }

        newController.view.frame = rectPrepared;
        newController.view.hidden = NO;

        [newController viewWillAppear:YES];
        [self.selectedTab.subViewController viewWillDisappear:YES];

        self.transNewTab = newItem;
        self.transNewController = newController;
        self.transOldTab = self.selectedTab;
        self.transOldController = self.selectedTab.subViewController;
        
        [UIView beginAnimations:@"viewTrans" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(viewTransitionFinished:finished:context:)];
        
        self.transNewController.view.frame = rect1;
        self.transOldController.view.frame = rectTrash;
        
        if ([self.transNewController respondsToSelector:@selector(refreshFullScreen)]) {
            [self.transNewController performSelector:@selector(refreshFullScreen)];
        }
        /*NSLog(@"New rect: %f,%f,%f,%f\nOld Rect: %f,%f,%f,%f\n", rect1.origin.x, rect1.origin.y, rect1.size.width, rect1.size.height, rectTrash.origin.x, rectTrash.origin.y, rectTrash.size.width, rectTrash.size.height);
        */
        [UIView commitAnimations];
        
        //[self activateBarItem:self.selectedTab highlighted:NO];
        //self.selectedTab.subViewController.view.hidden = YES;
        //newController.view.hidden = NO;
        //[self activateBarItem:newItem highlighted:YES];
        //[newController viewWillAppear:YES];
        
    }
    self.selectedTab = newItem;
}

-(void)viewTransitionFinished:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:@"viewTrans"] && finished)
    {
        [self activateBarItem:self.transOldTab highlighted:NO];
        [self activateBarItem:self.transNewTab highlighted:YES];
        [self.transNewController viewDidAppear:YES];
        [self.transOldController.view setHidden:YES];
        [self.transOldController viewDidDisappear:YES];
    }
}

-(TGTabBarItem *)tabBarItem:(NSUInteger)tag
{
    for(TGTabBarItem * tbi in self.tabBarItems.subviews)
    {
        if (tbi.tag == tag)
            return tbi;
    }
    return nil;
}

-(void)setNoteNumber:(NSInteger)noteNum forItem:(NSInteger)itemTag
{
    for(TGTabBarItem * tbi in self.tabBarItems.subviews)
    {
        if (tbi.tag == itemTag) {
            tbi.noteNumber = noteNum;
            [tbi setNeedsDisplay];
        }
    }
}


-(BOOL)setTabBarBackgroundImage:(NSUInteger)tag image:(UIImage *)image
{
    TGTabBarItem * tbi = [self tabBarItem:tag];
    [[tbi backgroundImageView] setImage:image];
    return tbi != nil;
}

-(NSInteger)addTabBarButtonWithText:(NSString *)aTitle withImage:(UIImage *)anImage controller:(UIViewController *)aViewController
{
    // begin sep part
    if (self.barSeparatorImage != nil && self.tabBarItems.subviews.count > 0)
    {
        UIImage * image = self.barSeparatorImage;
        UIImageView * imgv4 = [[UIImageView alloc] initWithImage:image];
        imgv4.tag = -1;
        imgv4.frame = CGRectMake([self availablePositionForControlInTabBar], 0,
                                 image.size.width, m_heightOfBar);
        [self.tabBarItems addSubview:imgv4];
        //[imgv4 release];
    }
    // end sep part
    // begin buton part
    TGTabBarItem * view3 = [[TGTabBarItem alloc] initWithFrame:CGRectMake([self availablePositionForControlInTabBar], 0, self.barItemWidth, m_heightOfBar)];
    view3.tag = m_barItemCounter++;
    view3.subViewController = aViewController;
    view3.delegate = self;

    UIImageView * imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.barItemWidth, m_heightOfBar)];
    imgv.hidden = YES;
    view3.backgroundImageView = imgv;
    [view3 addSubview:imgv];
    //[imgv release];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = view3.tag;
    [btn addTarget:self action:@selector(onTabButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(onTabButtonReleased:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(onTabButtonReleasedOut:) forControlEvents:UIControlEventTouchUpOutside];
    [btn setImage:anImage forState:UIControlStateNormal];
    btn.frame = CGRectMake(0,0,self.barItemWidth,self.barImageHeight);//self.tabBarItems.frame;
    btn.hidden = NO;
    [view3 addSubview:btn];
    
    UILabel * lab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.barImageHeight, self.barItemWidth, self.barTextHeight)];
    [lab setText:aTitle];
    lab.tag = view3.tag;
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setFont:self.barTextFont];
    [lab setBackgroundColor:[UIColor clearColor]];
    [lab setTextColor:self.barTextColor];
    [view3 addSubview:lab];
    // end button part
    [self activateBarItem:view3 highlighted:NO];
    [self.tabBarItems addSubview:view3];
    view3.titleLabel = lab;
    self.tabBarItems.bounds = CGRectMake(0.0, 0.0, [self availablePositionForControlInTabBar], m_heightOfBar);
    //[view3 release];
    //[lab release];
    
    [self showController:aViewController];
    
    return view3.tag;
}

-(CGFloat)availablePositionForControlInTabBar
{
    UIView * lastView = [[[self tabBarItems] subviews] lastObject];
    if (lastView) {
        return lastView.frame.origin.x + lastView.frame.size.width + 1;
    }
    return 0.0;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(CGRect)subviewControllerFrame
{
    return self.layerPresentation.frame;
}

-(void)toogleFullScreen
{
    isFullScreen = !isFullScreen;
    [self.tabBarItems setHidden:isFullScreen];
    [self.barBackgroundImageView setHidden:isFullScreen];
    CGRect frame = [self.layerPresentation frame];
    int diff = (isFullScreen ? + ((int)m_heightOfBar) : -((int)m_heightOfBar));
    CGRect frameNew = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height + diff);
    [self.layerPresentation setFrame:frameNew];
    [self.layerUnderPresentation setFrame:frameNew];
    
    for(TGTabBarItem * tabItem in self.tabBarItems.subviews)
    {
        if ([tabItem respondsToSelector:@selector(subViewController)]) {
            if ([tabItem.subViewController respondsToSelector:@selector(toogleFullScreen)])
            {
                [tabItem.subViewController performSelector:@selector(toogleFullScreen)];
            }
        }
    }
}

-(void)showController:(UIViewController *)subc1
{
    [self addChildViewController:subc1];
    subc1.view.frame = CGRectMake(0,0,self.layerPresentation.frame.size.width, self.layerPresentation.frame.size.height);
    subc1.view.hidden = YES;
    subc1.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.layerPresentation addSubview:subc1.view];
    [subc1 didMoveToParentViewController:self];
}

-(void)hideController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    @try {
        /*for(UIViewController * vc in self.subControllers)
        {
            [vc willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
        }*/
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
