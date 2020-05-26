//
//  SearchAdvancedDialog.m
//  VedabaseB
//
//  Created by Peter Kollath on 1/4/14.
//
//

#import "SearchAdvancedDialog.h"
#import "VBMainServant.h"
#import "SearchKeyboardAccessoryView.h"
#import "VBQueryTemplate.h"
#import "VBUserQuery.h"
#import "VBSearchManager.h"
#import "CIModel.h"
#import "VBFolioQuery.h"
#import "SelectQueryTemplateViewController.h"

@interface SearchAdvancedDialog ()

@end

@implementation SearchAdvancedDialog

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentQueryIndex = -1;
        currentScopeIndex = 0;
        queries = nil;
        tempTemplate = nil;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil template:(VBQueryTemplate *)templ
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentQueryIndex = -1;
        currentScopeIndex = 0;
        queries = nil;
        tempTemplate = templ;
    }
    return self;
}

- (IBAction)onTextFieldValueChanged:(id)sender {
    //NSLog(@"value changed");
    
    if (self.queryTemplate)
    {
        self.finalQueryLabel.text = [self.queryTemplate realQuery:[self.searchTextField text]];
    }
    else
    {
        self.finalQueryLabel.text = [self.searchTextField text];
    }
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (size.height > size.width)
    {
        self.searchTextField.inputAccessoryView.hidden = NO;
    }
    else
    {
        self.searchTextField.inputAccessoryView.hidden = YES;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.templateInfoPane setBackgroundColor:[VBMainServant colorForName:@"bodyHeaderTrans"]];
    
    SearchKeyboardAccessoryView * keyboard = [[SearchKeyboardAccessoryView alloc] initWithNibName:@"SearchKeyboardAccessoryView" bundle:nil];
    
    self.keyboardAccessoryViewController = keyboard;
    self.searchTextField.inputAccessoryView = self.keyboardAccessoryViewController.view;
    keyboard.textField = self.searchTextField;
    //[keyboard release];

}

-(VBUserQuery *)finalQuery
{
    VBUserQuery * query = [[VBUserQuery alloc] init];
    query.userQuery = [self.searchTextField text];
    query.userScope = currentScopeIndex;
    
    if (self.queryTemplate)
    {
        query.templateName = self.queryTemplate.templateName;
        query.templateString = self.queryTemplate.templateString;
    }
    
    return query;//[query autorelease];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.view.backgroundColor = [VBMainServant colorForName:@"headerBackground"];
    
    queries = [[self.mainServant currentFolio] queryHistory];
    currentQueryIndex = (int)[queries count];
    
    [self setTemplate:tempTemplate];
    [self setScopeIndex:0];

    [self updateDialogTitle];
    [self validateNavigButtons];
    [self.searchTextField becomeFirstResponder];
}

-(void)setTemplate:(VBQueryTemplate *)tpm
{
    self.queryTemplate = tpm;
    if (self.queryTemplate && [self.queryTemplate.templateName length] > 0)
    {
        [self.searchTextField setText:@""];
        self.templateInfoPane.hidden = NO;
        self.templateNameLabel.text = self.queryTemplate.templateName;
        self.finalQueryLabel.text = [self finalQuery].realQuery;
    }
    else
    {
        [self.searchTextField setText:@""];
        self.templateInfoPane.hidden = NO;
        self.templateNameLabel.text = @"";
        self.finalQueryLabel.text = @"";
    }
}

-(void)validateNavigButtons
{
    //NSLog(@"CurrentIndex: %d, ArrayCount: %lu", currentQueryIndex, (unsigned long)queries.count);
    [self.buttonPrevious setEnabled:(currentQueryIndex > 0)];
    BOOL b = currentQueryIndex < ((int)(queries.count) - 1);
    [self.buttonNext setEnabled:(b && currentQueryIndex >= 0)];
}


-(void)updateDialogTitle
{
    if (currentQueryIndex < 0 || queries.count == 0 || self.searchTextField.text.length == 0)
    {
        [self.dialogTitleLabel setText:@"Search query"];
    }
    else
    {
        [self.dialogTitleLabel setText:[NSString stringWithFormat:@"Search query %d/%lu", currentQueryIndex + 1, (unsigned long)queries.count]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];

    [self performSelector:@selector(onSearchTouchedIn:) withObject:self afterDelay:0];
    
	return YES;
}


- (IBAction)onSearchTouchedIn:(id)sender
{
    VBUserQuery * localQuery = [self finalQuery];
    
    if (queries.count > 0)
    {
        if ([[(VBUserQuery *)queries.lastObject userQuery] isEqualToString:localQuery.userQuery] == NO)
        {
            [queries addObject:localQuery];
        }
    }
    else
    {
        [queries addObject:localQuery];
    }

    currentQueryIndex = (int)queries.count - 1;
   	[self.searchTextField resignFirstResponder];
    [self closeDialog];
    
    
    SEL doActionSel = NSSelectorFromString((@"doAction:"));
    
    if (self.delegateSearch != nil && [self.delegateSearch respondsToSelector:doActionSel])
    {
        NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:localQuery, @"query",
                               @"search", @"action", nil];
        
        [self.delegateSearch performSelector:doActionSel withObject:dict afterDelay:0.0];
        
      
    }
    
    
    
}

- (IBAction)onClearTouchedIn:(id)sender {
    currentQueryIndex = (int)[queries count];
    [self setTemplate:nil];
    [self updateDialogTitle];
    [self validateNavigButtons];
}

/*! Handling event from button EXPLAIN
 \param sender
 \returns Returns void.
 */

- (IBAction)onExplainTouchedIn:(id)sender {
    //[self hideDialog];

    VBUserQuery * strQuery = [self finalQuery];
    if (queries.count > 0)
    {
        if ([[(VBUserQuery *)queries.lastObject userQuery] isEqualToString:strQuery.userQuery] == NO)
        {
            [queries addObject:strQuery];
        }
    }
    else
    {
        [queries addObject:strQuery];
    }
    [self.searchTextField resignFirstResponder];
    currentQueryIndex = (int)queries.count - 1;
    
    [self performSelectorInBackground:@selector(explainQueryTextAndShow:)
                           withObject:strQuery];
    
}

-(void)explainQueryTextAndShow:(VBUserQuery *)queryText
{
    VBMainServant * servant = [VBMainServant instance];
    //ContentItemModel * folioContent = [servant currentFolioContent];
    
    [servant.currentFolio saveShadow];
    
    [self.searchManager clear];
    
    /*BOOL useSel = ([self.folioContent selected] == NSMixedState);
    NSString * selectionText = nil;
    if (useSel) {
        selectionText = @"";
    }*/
    
    [self.searchManager performSearch:queryText selectedContent:self.scopeNameLabel.text
     currentRecord:[servant.userInterfaceManager currentRecordId]];
    [self performSelectorOnMainThread:@selector(explainQueryTextAndShowDidFinish)
                           withObject:nil waitUntilDone:NO];
}

-(void)explainQueryTextAndShowDidFinish
{
    if (self.searchManager.queries != nil && [self.searchManager.queries count] > 0)
    {
        VBFolioQueryOperator * oper = [self.searchManager.queries objectAtIndex:0];
        [oper gotoLastRecord];
        UIImage * image = [VBFolioQuery createImageFromQuery:oper];
        
        CGSize size = image.size;
        self.explainImageView.image = image;
        //[self.explainImageView sizeThatFits:size];
        self.explainScrollView.backgroundColor = [self.delegate.skinManager colorForName:@"bodyHeaderTrans"];
        self.explainScrollView.contentSize = size;
    }
}

-(void)setScopeIndex:(int)si
{
    currentScopeIndex = si;
    if (self.scopeNameLabel)
    {
        self.scopeNameLabel.text = [VBSearchManager scopeText:si];
    }
}


- (IBAction)onNextTouchedIn:(id)sender {
    currentQueryIndex++;
    VBUserQuery * q = [queries objectAtIndex:currentQueryIndex];
    [self setTemplate:q];
    [self setScopeIndex:q.userScope];
    [self.searchTextField setText:q.userQuery];
    [self updateDialogTitle];
    [self validateNavigButtons];
}
- (IBAction)onPreviousTouchedIn:(id)sender {
    currentQueryIndex--;
    VBUserQuery * q = [queries objectAtIndex:currentQueryIndex];
    [self setTemplate:q];
    [self setScopeIndex:q.userScope];
    [self.searchTextField setText:q.userQuery];
    [self updateDialogTitle];
    [self validateNavigButtons];
}
- (IBAction)onCloseTouchedIn:(id)sender {
    //[self hideDialog];
    [self closeDialog];
}

- (IBAction)onChooseTemplate:(id)sender
{
    SelectQueryTemplateViewController * dlg = [SelectQueryTemplateViewController sharedDialog];
    dlg.delegateSearch = self;
    dlg.delegate = [VBMainServant instance].userInterfaceManager;
    [dlg setTransitionDifference:0];
    
    [dlg openDialog];
}

-(void)startQueryUsingTemplate:(VBQueryTemplate *)tpm
{
    // Custom initialization
    [self setTemplate:tpm];
}

- (IBAction)onChooseScope:(id)sender
{
    [self setScopeIndex:(currentScopeIndex + 1) % 3];
}


@end
