//
//  BottomBarViewController.m
//  VedabaseB
//
//  Created by Peter Kollath on 23/08/14.
//
//

#import "BottomBarViewController.h"
#import "BottomBarView.h"
#import "VBMainServant.h"

@interface BottomBarViewController ()

@end

@implementation BottomBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.items = [[NSMutableArray alloc] init];
        self->backPathTitle = @"";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    ///self.barView.items = self.items;
    //self.barView.backgroundImage = self.backgroundImage;
    /*if (self.items.count > 0) {
        [self.barView setNeedsDisplay];
    }*/
/*    UIPanGestureRecognizer * pans = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.barView addGestureRecognizer:pans];
    
    UITapGestureRecognizer * taps = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.barView addGestureRecognizer:taps];*/
    
    ///self.barView.mainColor = [VBMainServant colorForName:@"darkGradientA"];
    ///self.barView.mainBottomColor = [VBMainServant colorForName:@"darkGradientB"];
    
    UIView * centralView = [self.barView viewWithTag:100];
    
    UIButton * button = nil;
    
    for(int tag = 200; tag <= 500; tag+=100)
    {
        button = (UIButton *)[centralView viewWithTag:tag];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateFocused];
    }
    self.barView.backgroundColor = [VBMainServant colorForName:@"darkGradientA"];
    self.textHeader.backgroundColor = [VBMainServant colorForName:@"headerBackground"];
    self.textHeaderLabel.text = self->backPathTitle;
}

-(void)viewWillAppear:(BOOL)animated
{
    ///CGFloat height = [self.barView calculateHeight:self.view.frame];
    ///[self.barView setFrame:CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height)];
    
    self.textHeaderLabel.text = self.titleBarText;
}

-(void)viewDidAppear:(BOOL)animated
{
    //[self.barView setNeedsDisplay];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    ///CGFloat height = [self.barView calculateHeight:self.view.frame];
    ///[self.barView setFrame:CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height)];
    //[self.barView setNeedsDisplay];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)addItem:(BottomBarItem *)bbi
{
    //[self.items addObject:bbi];
    //[self.barView setNeedsDisplay];
    //self.barView.autocorrectOffset = YES;
}

-(void)handlePanGesture:(id)sender
{
    UIPanGestureRecognizer * pans = (UIPanGestureRecognizer *)sender;
    
    if (pans.state == UIGestureRecognizerStateBegan)
    {
        //self.barView.touchedItemIndex = -1;
        [self.barView setNeedsDisplay];
    }
    else if (pans.state == UIGestureRecognizerStateChanged)
    {
//        [self.barView setNeedsDisplay];
    }
    else
    {
//        [self.barView setNeedsDisplay];
    }
}

-(void)handleTapGesture:(id)sender
{
    UITapGestureRecognizer * taps = (UITapGestureRecognizer *)sender;
    
    if (taps.state == UIGestureRecognizerStateBegan)
    {
        //CGPoint cp = [taps locationInView:self.barView];
        ///self.barView.touchedItemIndex = [self.barView determineItem:cp];
    }
    else if (taps.state == UIGestureRecognizerStateEnded)
    {
        //CGPoint cp = [taps locationInView:self.barView];
        /*self.barView.touchedItemIndex = [self.barView determineItem:cp];
        if (self.barView.touchedItemIndex >= 0)
        {
            [self.delegate bottomBar:self selectedItem:[self.items objectAtIndex:self.barView.touchedItemIndex]];
        }
        else
        {
            [self.delegate bottomBar:self selectedItem:nil];
        }
        self.barView.touchedItemIndex = -1;
        [self.barView setNeedsDisplay];
         */
    }
}

-(void)onTabButtonPressed:(id)sender
{
    if (sender == self.view)
    {
        [self.delegate bottomBar:self selectedItem:nil];
    }
}

-(void)setPathTitle:(NSString *)str
{
    if (self.textHeaderLabel == nil)
    {
        self->backPathTitle = str;
    }
    else
    {
        self.textHeaderLabel.text = str;
    }
}

-(void)looseViewClicked:(id)sender
{
    [self.delegate bottomBar:self selectedItem:nil];
}

-(IBAction)onShowContent:(id)sender
{
    [self.delegate showContent];
}

-(IBAction)onShowSearch:(id)sender
{
    [self.delegate showSearch];
}

-(IBAction)onShowDictionary:(id)sender
{
    [self.delegate showDictionary];
}

-(IBAction)onShowTextLayout:(id)sender
{
    [self.delegate showTextSettings];
}

@end
