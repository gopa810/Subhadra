    //
//  VCContent2.m
//  VedabaseB
//
//  Created by Peter Kollath on 1/29/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import "ContentPageController.h"
#import "ContentTableController.h"
#import "VCHelpMainViewController.h"
#import "ContentTableItemView.h"

@implementation ContentPageController

@synthesize tableController;
@synthesize contentTable;
@synthesize headView;



#pragma mark -
#pragma mark System Methods

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self                                                 selector:@selector(notificationReceived:) name:kNotifyFolioOpen object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self                                                 selector:@selector(notificationReceived:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self                                                 selector:@selector(notificationReceived:) name:kNotifyCmdSelectFolio object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"VBContentManager_changedFolio" object:nil];
        isFullScreen = NO;
        folioToSet = nil;
        self.startingRecord = 0;
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //VBMainServant * appDelegate = [VBMainServant instance];
    
    ContentTableController * f = [[ContentTableController alloc] initWithStyle:UITableViewStylePlain];
    self.tableController = f;
    //[f release];
    self.tableController.view = self.contentTable;
    self.tableController.tableView = self.contentTable;
    self.tableController.contentPageDelegate = self.delegate;
    self.tableController.parent = self;
    self.contentTable.dataSource = self.tableController;
    self.contentTable.delegate = self.tableController;
    
    
    f.contentManager = self.contentManager;
    f.userInterfaceManager = self.userInterfaceManager;
    f.startingRecord = self.startingRecord;
    [f setFolio:folioToSet];
    folioToSet = nil;
    
    //[[VBMainServant instance] setCurrentContentView:self.tableController];
    
    /*if (appDelegate.needLoadContent)
     {
     [self.tableController initializeStartData:nil];
     appDelegate.needLoadContent = NO;
     }*/
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.contentTable setBackgroundColor:[VBMainServant colorForName:@"bodyBackground"]];
    [self.headView setBackgroundColor:[VBMainServant colorForName:@"headerBackground"]];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(swipeRightAction:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRight.delegate = self;
    [self.contentTable addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeftAction:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.delegate = self;
    [self.contentTable addGestureRecognizer:swipeLeft];
    
    //[self.backButton setBackgroundColor:[UIColor clearColor]];
    //[self.backButton setTitle:@"" forState:UIControlStateNormal];
    //[self.backButton setImage:[VBMainServant imageForName:@"back_white"] forState:UIControlStateNormal];
    //[self.backButton addTarget:self action:@selector(onBackButton:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(IBAction)showHelpPage:(id)sender
{
    VCHelpMainViewController * help = [[VCHelpMainViewController alloc] initWithNibName:@"VCHelpMainViewController" bundle:nil];
    
    help.delegate = (VBUserInterfaceManager *)self.delegate;
    [help openDialog];
}

-(UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}



#pragma mark -
#pragma mark Custom Methods

-(void)notificationReceived:(NSNotification *)note
{
    if ([note.name isEqualToString:kNotifyFolioOpen])
    {
        VBFolio * folio = [note.userInfo objectForKey:@"folio"];
        if (folio)
        {
            NSDictionary * dict = [note.userInfo objectForKey:@"dictionary"];
            [self setPageTitle:folio.title];
            [self setPageImage:[UIImage imageWithData:[dict objectForKey:@"Image"]]];
        }
    }
    else if ([note.name isEqualToString:UIDeviceOrientationDidChangeNotification]) {
        [self.tableController.tableView reloadData];
    }
    else if ([note.name isEqualToString:@"VBContentManager_changedFolio"])
    {
        [self.tableController performSelector:@selector(loadItems:) withObject:self.tableController.lastPageLoaded];
    }
}

-(void)setFolio:(VBFolio *)ifolio
{
    folioToSet = ifolio;
}




- (void)swipeRightAction:(id)ignored
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger action = [userDefaults integerForKey:@"cs_swiperight_action"];

    if (action == -1)
    {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Select Action" message:@"You are performing this swipe from left to right for the first time. Please select action you want to perform next time. If you want to perform selected action, repeat your gesture once again." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Go to parent content item" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [userDefaults setInteger:(NSInteger)1 forKey:@"cs_swiperight_action"];
            [alert dismissViewControllerAnimated:YES completion:^{  }];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Hide contents screen" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [userDefaults setInteger:(NSInteger)2 forKey:@"cs_swiperight_action"];
            [alert dismissViewControllerAnimated:YES completion:^{  }];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel this dialog" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // cancel dialog
            [alert dismissViewControllerAnimated:YES completion:^{  }];
        }]];
        [self presentViewController:alert animated:YES completion:^{  }];
 
    }
    else if (action == 1)
    {
        [self.tableController loadParentIfPossible];
    }
    else if (action == 2)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(contentPage:shouldHide:)])
        {
            [self.delegate contentPage:self shouldHide:YES];
        }
    }
}

- (void)swipeLeftAction:(UISwipeGestureRecognizer *)recognizer
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger action = [userDefaults integerForKey:@"cs_swipeleft_action"];
    
    if (action == -1)
    {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Select Action" message:@"You are performing this swipe from right to left for the first time. Please select action you want to perform next time. If you want to perform selected action, repeat your gesture once again." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Expand item" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [userDefaults setInteger:(NSInteger)1 forKey:@"cs_swipeleft_action"];
            [alert dismissViewControllerAnimated:YES completion:^{  }];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Hide contents screen" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [userDefaults setInteger:(NSInteger)2 forKey:@"cs_swipeleft_action"];
            [alert dismissViewControllerAnimated:YES completion:^{  }];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel this dialog" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // cancel dialog
            [alert dismissViewControllerAnimated:YES completion:^{  }];
        }]];
        [self presentViewController:alert animated:YES completion:^{  }];
    }
    else if (action == 1)
    {
        CGPoint pt = [recognizer locationInView:self.tableController.tableView];
        [self.tableController activateCellAtPoint:pt];
    }
    else if (action == 2)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(contentPage:shouldHide:)])
        {
            [self.delegate contentPage:self shouldHide:YES];
        }
    }
}

-(void)setPageTitle:(NSString *)aTitle
{

}

-(void)setPageImage:(UIImage *)anImage
{

}

-(void)toogleFullScreen
{
    isFullScreen = !isFullScreen;
    [self.headView setHidden:isFullScreen];

    [self refreshFullScreen];
}

-(void)refreshFullScreen
{

}

-(IBAction)closeWindow:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contentPage:shouldHide:)])
    {
        [self.delegate contentPage:self shouldHide:YES];
    }
}

-(void)saveUIState
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    [settings setValue:self.tableController.lastPageLoaded
                forKey:@"lastContentPageLoaded"];
    
}

-(void)restoreUIState
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    NSString * key = [settings stringForKey:@"lastContentPageLoaded"];
    [self.tableController loadItems:key];
}



@end
