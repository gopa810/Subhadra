//
//  TextStyleViewController.m
//  VedabaseB
//
//  Created by Peter Kollath on 1/26/13.
//
//

#import "TextStyleViewController.h"
#import "VBUserInterfaceManager.h"
#import "VBMainServant.h"
#import "FDCharFormat.h"
#import "EndlessTextView.h"
#import "FlatParagraph.h"

float multiDiff = 1.172f;

@interface TextStyleViewController ()

@end

@implementation TextStyleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(float)getExponentValue:(int)pos withStartValue:(float)startValue
{
    float value = startValue;
    if (pos < 0)
        pos = 0;
    if (pos > 10)
        pos = 10;
    for(int i = 0; i < pos; i++)
    {
        value *= multiDiff;
    }
    return value;
}

-(int)getExponentForValue:(float)value withStartValue:(float)startValue
{
    float valueS = startValue;
    int i;
    for(i = 0; i < 10; i++)
    {
        if (valueS*multiDiff > value)
            return i;
        valueS *= multiDiff;
    }
    return i;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.normalColor = [UIColor clearColor];
    self.highlightColor = [UIColor blackColor];

    self.closeArea.touchCommand = @"closeDialog";
    self.view.backgroundColor = [UIColor clearColor];
    self.visibleAreaView.sides = UIRectEdgeTop;
    self.visibleAreaView.mainColor = [VBMainServant colorForName:@"darkGradientA"];
    self.visibleAreaView.mainBottomColor = [VBMainServant colorForName:@"darkGradientB"];
//    self.visibleAreaView.backgroundColor = [VBMainServant colorForName:@"lite_papyrus"];
    // Do any additional setup after loading the view from its nib.
    



}

-(void)viewWillAppear:(BOOL)animated
{
    self.textSizeStepper.minimumValue = 0;
    self.textSizeStepper.maximumValue = [self getExponentForValue:[FDCharFormat multiplyFontSizeMax]
                                                   withStartValue:[FDCharFormat multiplyFontSizeMin]];
    self.textSizeStepper.value = [self getExponentForValue:[FDCharFormat multiplyFontSize]
                                            withStartValue:[FDCharFormat multiplyFontSizeMin]];
    
    self.lineSpacingStepper.minimumValue = 0;
    self.lineSpacingStepper.maximumValue = [self getExponentForValue:[FDCharFormat multiplySpacesMax]
                                                      withStartValue:[FDCharFormat multiplySpacesMin]];
    self.lineSpacingStepper.value = [self getExponentForValue:[FDCharFormat multiplySpaces]
                                               withStartValue:[FDCharFormat multiplySpacesMin]];
    
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    self.marginStepper.stepValue = [ud doubleForKey:@"paddingStepSize"];
    self.marginStepper.value = self.userInterfaceManager.drawer.paddingLeft;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Touch Delegate

-(void)onTabButtonPressed:(id)sender
{
    [self onCloseToolbar:self];
}

-(void)onTabButtonReleased:(id)sender
{
}

-(void)onTabButtonReleasedOut:(id)sender
{
}

-(void)executeTouchCommand:(NSString *)command data:(NSDictionary *)aData
{
    if ([command isEqualToString:@"closeDialog"]) {
        [self onCloseToolbar:self];
    }
}

-(void)highlightFontTypeWithFont:(NSString *)fontName
{
    //NSLog(@"fontTypeWithFont");
    if (![fontName isEqualToString:@"Times"]) {
    } else {
    }
}

- (IBAction)onCloseToolbar:(id)sender {
    [self.userInterfaceManager removeViewController:self toSide:CGSizeMake(0, -20)
                                               name:@"TextSettingsDialog"];
}

- (IBAction)onFontTypeSerif:(id)sender {

    [FlatParagraph setDefaultFont:[FDTypeface TIMES_FONT]];
    [self.userInterfaceManager setNeedsDisplayText];
}

- (IBAction)onFontTypeSansSerif:(id)sender {

    [FlatParagraph setDefaultFont:[FDTypeface ARIAL_FONT]];
    [self.userInterfaceManager setNeedsDisplayText];
}


-(IBAction)onTextSizeStepperChange:(id)sender
{
    [FDCharFormat setMultiplyFontSize: [self getExponentValue:(float)self.textSizeStepper.value
                                               withStartValue:[FDCharFormat multiplyFontSizeMin]]];
    [self.userInterfaceManager setNeedsDisplayText];
}

-(IBAction)onLineSpaceStepperChange:(id)sender
{
    [FDCharFormat setMultiplySpaces: [self getExponentValue:(int)self.lineSpacingStepper.value
                                             withStartValue:[FDCharFormat multiplySpacesMin]]];
    [self.userInterfaceManager setNeedsDisplayText];
}

-(IBAction)onMarginStepperChange:(id)sender
{
    self.userInterfaceManager.drawer.paddingLeft = self.marginStepper.value;
    self.userInterfaceManager.drawer.paddingRight = self.marginStepper.value;
    [self.userInterfaceManager setNeedsDisplayText];
    
    UIDevice * dev = [UIDevice currentDevice];
    NSString * key = @"EndlessMargins";
    if (UIDeviceOrientationIsLandscape(dev.orientation))
        key = @"EndlessMarginsLandscape";
    
    NSUserDefaults * user = [NSUserDefaults standardUserDefaults];
    [user setDouble:self.marginStepper.value forKey:key];
    [user synchronize];
}

@end
