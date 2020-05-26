//
//  SelectUserStringDialog.m
//  VedabaseB
//
//  Created by Peter Kollath on 21/11/14.
//
//

#import "SelectUserStringDialog.h"
#import "VBUserInterfaceManager.h"
#import "VBSkinManager.h"

@interface SelectUserStringDialog ()

@end

@implementation SelectUserStringDialog

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.strings = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.headerBack.backgroundColor = [self.delegate.skinManager colorForName:@"darkGradientA"];
    self.tableController.strings = self.strings;
    self.tableController.tableView = self.tableView;
    self.tableController.imageItem = [self.delegate.skinManager imageForName:@"cont_folder"];
    [self.tableController.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setStrings:(NSArray *)strings
{
    _strings = strings;
    self.tableController.strings = strings;
}

-(NSArray *)strings
{
    return _strings;
}

-(void)setDialogTitle:(NSString *)strTitle
{
    self.titleLabel.text = strTitle;
}



-(IBAction)onClose:(id)sender
{
    if (self.callbackDelegate)
    {
        NSDictionary * selectedItem = nil;
        if (self.tableController.selectedRow >= 0 && self.tableController.selectedRow < self.strings.count)
            selectedItem = [self.strings objectAtIndex:self.tableController.selectedRow];
        if (selectedItem != nil)
            [self.callbackDelegate userHasSelectedItem:selectedItem inDialog:self.tag userInfo:self.userInfo];
    }
    [self closeDialog];
}

-(IBAction)onCancel:(id)sender
{
    [self closeDialog];
}



@end
