//
//  ShowViewRecordsController.m
//  VedabaseB
//
//  Created by Peter Kollath on 04/11/14.
//
//

#import "ShowViewRecordsController.h"
#import "VBUserInterfaceManager.h"
#import "VBSkinManager.h"
#import "VBMainServant.h"
#import "EndlessScrollView.h"

@interface ShowViewRecordsController ()

@end

@implementation ShowViewRecordsController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id)delegate
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.delegate = delegate;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
/*    self.listController = [[EndlessListViewController alloc] initWithStyle:UITableViewStylePlain];
    self.listController.view = self.tableView;
    self.listController.tableView = self.tableView;
    self.listController.dataSource = self.source;
    self.tableView.delegate = self.listController;
    self.tableView.dataSource = self.listController;
    self.tableView.backgroundColor = [self.delegate.skinManager colorForName:@"bodyBackground"];
    self.listController.drawer = [VBMainServant instance].drawer;*/
    
    self.textView.delegate = self;
    self.textView.drawer = [VBMainServant instance].drawer;
    self.textView.dataSource = self.source;
    [self.textView setSkin:self.delegate.skinManager];
    self.textView.backgroundColor = [self.delegate.skinManager colorForName:@"bodyBackground"];
    
    VBSkinManager * skin = self.delegate.skinManager;
    
    self.view.backgroundColor = [skin colorForName:@"headerBackground"];
    
    self.topBar.mainColor = [skin colorForName:@"darkGradientB"];
    self.topBar.mainBottomColor = [skin colorForName:@"darkGradientA"];
    self.bottomBar.mainColor = [skin colorForName:@"darkGradientA"];
    self.bottomBar.mainBottomColor = [skin colorForName:@"darkGradientB"];
    self.bottomBar.sides = UIRectEdgeTop;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setSource:(ETVRecords *)source
{
    _source = source;
    self.textView.dataSource = self.source;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)onCloseButton:(id)sender
{
    [self closeDialog];
}

#pragma mark -
#pragma mark User Interface

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.textView rearrangeForOrientation];
}

-(void)setCurrentRecord:(int)recId
{
    [self.textView setCurrentRecord:recId offset:0];
}

#pragma mark -
#pragma mark Endles Delegate

-(void)endlessShowInMainView:(id)sender
{
    [self closeDialog];
    FDRecordBase * rec = [self.source getRawRecord:self.userInteractedRecordId];
    [self.delegate contentPage:self.delegate.contentBarController shouldHide:YES];
    [self.delegate loadRecord:rec.linkedRecordId useHighlighting:NO];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(endlessShowInMainView:))
    {
        return YES;
    }
    if (action == @selector(copy:))
    {
        return YES;
    }
    
    return NO;
}

-(void)copy:(id)sender
{
    UIPasteboard * paste = [UIPasteboard generalPasteboard];
    
    NSMutableDictionary * newPasteboardContent = [[NSMutableDictionary alloc] init];
    NSData * data = [[self.textView getSelectedText:NO] dataUsingEncoding:NSUTF8StringEncoding];
    [newPasteboardContent setObject:data forKey:@"public.text"];
    
    
    paste.items = [NSArray arrayWithObject:newPasteboardContent];
}

-(void)endlessTextView:(UIView *)textView rightAreaClicked:(int)recId withRect:(CGRect)rect
{
    [self endlessTextView:textView leftAreaClicked:recId withRect:rect];
}

-(void)endlessTextView:(UIView *)textView rightAreaLongClicked:(int)recId withRect:(CGRect)rect
{
    [self endlessTextView:textView leftAreaClicked:recId withRect:rect];
}

-(void)endlessTextView:(UIView *)textView leftAreaClicked:(int)recId withRect:(CGRect)rect
{
    self.userInteractedRecordId = recId;

    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Show in Main Text" action:@selector(endlessShowInMainView:)];
    [self becomeFirstResponder];
    UIMenuController * theMenu = [UIMenuController sharedMenuController];
    [theMenu setTargetRect:rect inView:textView];
    theMenu.menuItems = [NSArray arrayWithObject:menuItem];
    [theMenu setMenuVisible:YES animated:YES];
}

-(void)endlessTextView:(UIView *)textView leftAreaLongClicked:(int)recId withRect:(CGRect)rect
{
}

-(void)endlessTextView:(UIView *)textView selectionDidChange:(CGRect)rect
{
    [self becomeFirstResponder];
    UIMenuController * theMenu = [UIMenuController sharedMenuController];
    [theMenu setTargetRect:rect inView:textView];
    [theMenu setMenuVisible:YES animated:YES];
}

-(void)endlessTextView:(UIView *)textView navigateLink:(NSDictionary *)data
{
    NSLog(@"LINK *** %@ *** %@", [data valueForKey:@"TYPE"], [data valueForKey:@"LINK"]);
    
}

-(void)endlessTextView:(UIView *)textView swipeRight:(CGPoint)point
{
}

-(void)endlessTextView:(UIView *)textView swipeLeft:(CGPoint)point
{
}

-(void)endlessTextViewTapWithoutSelection:(UIView *)textView
{
}

@end
