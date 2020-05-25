//
//  StoreViewController.m
//  VedabaseB
//
//  Created by Peter Kollath on 12/28/12.
//  Copyright (c) 2012 GPSL. All rights reserved.
//

#import "StoreViewController.h"

@interface StoreViewController ()

@end

@implementation StoreViewController

@synthesize headerBarView;
@synthesize ftc;
@synthesize folios;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:kNotifyCollectionsListChanged
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notificationReceived:)
                                                     name:kNotifyLocalFolioListChanged
                                                   object:nil];
    }
    return self;
}

-(void)notificationReceived:(NSNotification *)note
{
    if ([note.name isEqualToString:kNotifyCollectionsListChanged])
    {
        [[VBMainServant instance].fileManager refreshLinksToDownloadedFiles];
        [self.ftc.tableView reloadData];
    }
    else if ([note.name isEqualToString:kNotifyLocalFolioListChanged])
    {
        [self.ftc.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FolioFilesTableViewController * f = [[FolioFilesTableViewController alloc] initWithStyle:UITableViewStylePlain];
	self.ftc = f;
	//[f release];
	self.ftc.view = self.folios;
	self.ftc.tableView = self.folios;
    self.folios.dataSource = f;
    self.folios.delegate = f;
    
    
    // Do any additional setup after loading the view from its nib.
    [self.headerBarView setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    //self.folios.backgroundView = self.view;
    self.folios.backgroundView = nil;
    //self.folios.backgroundColor = [VBMainServant colorForName:@"body1"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

/*-(void)localStorageListUpdated
{
    [self.ftc.tableView reloadData];
}

-(void)remoteStorageListUpdated
{
    [self.ftc.tableView reloadData];
}*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
