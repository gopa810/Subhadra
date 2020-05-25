    //
//  FolioSelectDialog.m
//  VedabaseB
//
//  Created by Peter Kollath on 1/29/11.
//  Copyright 2011 GPSL. All rights reserved.
//

#import "FolioSelectDialog.h"
#import "VBMainServant.h"

@implementation FolioSelectDialog


@synthesize folios;
@synthesize ftc;
@synthesize waitLabel, btnSelect, btnRemove;
@synthesize delegate;
@synthesize selectedFolio;
@synthesize activityView, shadowTop, shadowBottom;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	FolioTableController * f = [[FolioTableController alloc] initWithStyle:UITableViewStylePlain];
	self.ftc = f;
	//[f release];
	self.ftc.view = self.folios;
	self.ftc.tableView = self.folios;
	self.ftc.selectedRow = -1;
	self.ftc.btnSelect = self.btnSelect;
    self.ftc.btnRemove = self.btnRemove;
	self.folios.dataSource = self.ftc;
	self.folios.delegate = self.ftc;
	[self.folios reloadData];
    
    [self.view setBackgroundColor:[VBMainServant colorForName:@"bodyBackground"]];
    [self.shadowTop setImage:[VBMainServant imageForName:@"shadow1_top"]];
    [self.shadowBottom setImage:[VBMainServant imageForName:@"shadow1_bottom"]];
    
    
    NSString * dateStr = [NSString stringWithUTF8String:__DATE__];
    versionLabel.text = [NSString stringWithFormat:@"AppVersion: %@", dateStr];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:kNotifyCollectionsListChanged object:nil];
    
}

-(void)notificationReceived:(NSNotification *)aNote
{
    if ([aNote.name isEqualToString:kNotifyCollectionsListChanged])
    {
        //NSLog(@"FolioSelectDialog has received notification: %@", kNotifyCollectionsListChanged);
        [self setWaitingStatus:NO];
        NSArray * folioList = [aNote.userInfo valueForKey:@"collections"];
        self.ftc.arrFolios = folioList;
        [self.folios reloadData];
    }
}

-(void)setWaitingStatus:(BOOL)ws
{
	if (ws)
	{
		CGPoint cp = self.folios.center;
		self.waitLabel.center = cp;
		cp.y += 40.0;
		self.activityView.center = cp;
        self.waitLabel.text = @"Initializing list...";
		[self.activityView startAnimating];
	}
	else 
	{
		[self.activityView stopAnimating];
	}
	self.activityView.hidden = !ws;
	self.waitLabel.hidden = ! ws;
	self.folios.hidden = ws;
}

/*-(void)backgroundReadFolios
{
	VBMainServant * appdeleg = (VBMainServant *)[[UIApplication sharedApplication] delegate];
    NSLog(@"enumerateFolios in -(void)backgroundReadFolios");
	[appdeleg enumerateFolios];
    [self performSelectorOnMainThread:@selector(updateFoliosTable:)
                           withObject:@""
                        waitUntilDone:NO];
	
}

-(void)updateFoliosTable:(id)sender
{
	[self.folios reloadData];
	[self setWaitingStatus:NO];
}*/

-(void)initializeTableView
{
    // start reading unpacked and folios
    if ([[VBMainServant instance].fileManager enumerateFolios])
    {
        self.ftc.arrFolios = [[VBMainServant instance].fileManager folioList];
        [self.folios reloadData];
    }
    else
    {
        [self setWaitingStatus:YES];
    }
    //[self performSelectorInBackground:@selector(backgroundReadFolios) withObject:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
	//[self initializeTableView];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.folios = nil;
	self.waitLabel = nil;
	self.btnSelect = nil;
    self.btnRemove = nil;
	self.selectedFolio = nil;
	self.ftc = nil;
	self.activityView = nil;
    self.shadowTop = nil;
    self.shadowBottom = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	//[folios release];
	//[waitLabel release];
	//[btnSelect release];
	//[selectedFolio release];
	//[ftc release];
	//[activityView release];
    //[super dealloc];
}


-(IBAction)done:(id)sender
{
	self.selectedFolio = nil;
    //self.folioToRemove = nil;
	if (self.ftc.selectedRow >= 0)
	{
		self.selectedFolio = [self.ftc.arrFolios objectAtIndex:self.ftc.selectedRow];
	}
	[self.delegate selectFolioControllerDidFinish:self];
}

-(IBAction)doneCancel:(id)sender
{
	self.selectedFolio = nil;
    //self.folioToRemove = nil;
	[self.delegate selectFolioControllerDidFinish:self];
}

-(void)refreshTable
{
    [self.folios reloadData];
}

@end
