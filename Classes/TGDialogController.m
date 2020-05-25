//
//  TGDialogController.m
//  VedabaseB
//
//  Created by Peter Kollath on 8/17/13.
//
//

#import "TGDialogController.h"
#import "Constants.h"
#import "VBMainServant.h"

@interface TGDialogController ()

@end

@implementation TGDialogController

-(id)init
{
    self = [super init];
    if (self)
    {
        self.messageDelegate = nil;
    }
    return self;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

-(void)onTabButtonPressed:(id)sender
{
    if (self.messageDelegate)
    {
        [self.messageDelegate onTabButtonPressed:sender];
    }
}

-(void)onTabButtonReleased:(id)sender
{
    if (self.messageDelegate)
    {
        [self.messageDelegate onTabButtonReleased:sender];
    }
}

-(void)onTabButtonReleasedOut:(id)sender
{
    if (self.messageDelegate)
    {
        [self.messageDelegate onTabButtonReleasedOut:sender];
    }
}

-(void)executeTouchCommand:(NSString *)command data:(NSDictionary *)aData
{
    if (self.messageDelegate)
    {
        [self.messageDelegate executeTouchCommand:command data:aData];
    }
}


-(void)showDialog
{
    self.view.hidden = NO;
}

-(void)hideDialog
{
    self.view.hidden = YES;
}

-(void)closeDialog
{
    //[self.view removeFromSuperview];
    [[VBMainServant instance] removeControllerFromSubs:self];
    //[self autorelease];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

-(void)dialogControllerNotificationReceived:(NSNotification *)note
{
    if ([note.name isEqualToString:kNotifyCmdCloseAllDialogs])
    {
        [self closeDialog];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dialogControllerNotificationReceived:) name:kNotifyCmdCloseAllDialogs object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotifyCmdCloseAllDialogs object:nil];
}

@end
