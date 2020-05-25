//
//  VCHelpMainViewController.m
//  VedabaseB
//
//  Created by Peter Kollath on 20/11/14.
//
//

#import "VCHelpMainViewController.h"

@interface VCHelpMainViewController ()

@end

@implementation VCHelpMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)onLinkShow:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://vedabase.home.sk"]];
}

-(IBAction)onClose:(id)sender
{
    [self closeDialog];
}

@end
