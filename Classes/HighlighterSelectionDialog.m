//
//  HighlighterSelectionDialog.m
//  VedabaseB
//
//  Created by Peter Kollath on 8/17/13.
//
//

#import "HighlighterSelectionDialog.h"
#import "VBMainServant.h"

@interface HighlighterSelectionDialog ()

@end

@implementation HighlighterSelectionDialog

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.grayBack.touchCommand = @"dismiss";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.grayBack.frame = self.view.frame;
    self.buttonsContainerView.backgroundColor = [VBMainServant colorForName:@"bodyBackground"];
}


- (IBAction)onSelectOrange:(id)sender {
    [self hideDialog];
    [self.delegate executeTouchCommand:@"highlightText" data:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:6] forKey:@"highlighterId"]];
    [self closeDialog];
}

- (IBAction)onSelectPurple:(id)sender {
    [self hideDialog];
    [self.delegate executeTouchCommand:@"highlightText" data:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:7] forKey:@"highlighterId"]];
    [self closeDialog];
}

- (IBAction)onSelectBlue:(id)sender {
    [self hideDialog];
    [self.delegate executeTouchCommand:@"highlightText" data:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:8] forKey:@"highlighterId"]];
    [self closeDialog];
}

- (IBAction)onSelectClear:(id)sender {
    [self hideDialog];
    [self.delegate executeTouchCommand:@"highlightText" data:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"highlighterId"]];
    [self closeDialog];
}

- (IBAction)onBackButton:(id)sender {
    [self hideDialog];
    [self closeDialog];
}

- (IBAction)onSelectYellow:(id)sender {
    [self hideDialog];
    [self.delegate executeTouchCommand:@"highlightText" data:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"highlighterId"]];
    [self closeDialog];
}

- (IBAction)onSelectGreen:(id)sender {
    [self hideDialog];
    [self.delegate executeTouchCommand:@"highlightText" data:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:@"highlighterId"]];
    [self closeDialog];}

- (IBAction)onSelectCyan:(id)sender {
    [self hideDialog];
    [self.delegate executeTouchCommand:@"highlightText" data:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:3] forKey:@"highlighterId"]];
    [self closeDialog];
}

- (IBAction)onSelectRed:(id)sender {
    [self hideDialog];
    [self.delegate executeTouchCommand:@"highlightText" data:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:4] forKey:@"highlighterId"]];
    [self closeDialog];
}

- (IBAction)onSelectMagenta:(id)sender {
    [self hideDialog];
    [self.delegate executeTouchCommand:@"highlightText" data:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:5] forKey:@"highlighterId"]];
    [self closeDialog];
}

#pragma mark -
#pragma mark Touch delegate Methods

-(void)onTabButtonPressed:(id)sender
{
    self.view.alpha = 0.5;
}

-(void)onTabButtonReleased:(id)sender
{
    self.view.alpha = 1.0;
    [self onBackButton:self];
}

-(void)onTabButtonReleasedOut:(id)sender
{
    self.view.alpha = 1.0;
}

#pragma mark -
#pragma mark memory management


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setButtonsContainerView:nil];
    [super viewDidUnload];
}
@end
