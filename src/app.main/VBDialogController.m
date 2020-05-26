//
//  VBDialogController.m
//  VedabaseB
//
//  Created by Peter Kollath on 06/09/14.
//
//

#import "VBDialogController.h"
#import "VBUserInterfaceManager.h"

@interface VBDialogController ()

@end

@implementation VBDialogController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.transitionMode = 0;
        self.transitionDiff = 40.0;
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

-(void)setTransitionDifference:(CGFloat)diff
{
    self.transitionDiff = diff;
    self.transitionMode = 0;
}

-(void)setTransitionOffset:(CGSize)size
{
    self.transitionOff = size;
    self.transitionMode = 1;
}

-(void)showDialog
{
    self.view.hidden = NO;
}

-(void)hideDialog
{
    self.view.hidden = YES;
}

-(void)openDialog
{
    if ([self.delegate.view.subviews indexOfObjectIdenticalTo:self.view] == NSNotFound)
    {
        if (self.transitionMode == 0)
        {
            [self.delegate insertViewController:self withDiff:self.transitionDiff];
        }
        else
        {
            [self.delegate insertViewController:self fromSide:self.transitionOff];
        }
    }
}

-(void)closeDialog
{
    if (self.transitionMode == 0)
    {
        [self.delegate removeViewController:self withDiff:self.transitionDiff name:@""];
    }
    else
    {
        [self.delegate removeViewController:self toSide:self.transitionOff name:@""];
    }
}

@end
