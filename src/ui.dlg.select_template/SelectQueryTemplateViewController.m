//
//  SelectQueryTemplateViewController.m
//  VedabaseB
//
//  Created by Peter Kollath on 1/6/14.
//
//

#import "SelectQueryTemplateViewController.h"
#import "VBMainServant.h"
#import "VBQueryTemplate.h"

@interface SelectQueryTemplateViewController ()

@end

@implementation SelectQueryTemplateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.templates = [VBMainServant instance].templates;
    }
    return self;
}

+(SelectQueryTemplateViewController *)sharedDialog
{
    SelectQueryTemplateViewController * dlg = [[SelectQueryTemplateViewController alloc] initWithNibName:@"SelectQueryTemplateViewController" bundle:nil];
    
    return dlg;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.partView setBackgroundColor:[VBMainServant colorForName:@"darkGradientA"]];
    [self.shadeView setBackgroundColor:[UIColor blackColor]];
    [self.shadeView setAlpha:0.3];
    [self.shadeView setFrame: self.view.frame];
    
    self.selectedTemplateIndex = -1;
    self.btnAccept.enabled = NO;
    
}


- (IBAction)onAcceptButton:(id)sender {
    
    SEL selector = NSSelectorFromString(@"startQueryUsingTemplate:");
    if (self.delegateSearch != nil && [self.delegateSearch respondsToSelector:selector])
    {
        id selectedObject = self.selectedTemplateIndex > 0 ?
                                [self.templates objectAtIndex:self.selectedTemplateIndex - 1] :
                                nil;
        [self.delegateSearch performSelector:selector
                                  withObject:selectedObject
                                  afterDelay:0];
    }
    
    [self closeDialog];
    
}

- (IBAction)onCloseButton:(id)sender {
    
    [self closeDialog];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.templates count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        //cell.selectedBackgroundView = self.selectedBackgroundView;
    }
    
    // Configure the cell...
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"<None>";
    }
    else
    {
        VBQueryTemplate * qt = [self.templates objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = qt.templateName;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedTemplateIndex = indexPath.row;
    self.btnAccept.enabled = YES;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedTemplateIndex = -1;
    self.btnAccept.enabled = NO;
}





@end
