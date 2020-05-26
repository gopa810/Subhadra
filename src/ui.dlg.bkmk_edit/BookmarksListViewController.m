//
//  BookmarksListViewController.m
//  VedabaseB
//
//  Created by Peter Kollath on 8/21/13.
//
//

#import "BookmarksListViewController.h"
#import "VBMainServant.h"

@interface BookmarksListViewController ()

@end

@implementation BookmarksListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        folio = [[VBMainServant instance] currentFolio];
        
        UIView * selBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        selBack.backgroundColor = [VBMainServant colorForName:@"hdr_big"];
        
        self.selectedBackgroundView = selBack;
        self.currentBookmarkParentId = -1;
        
        //[selBack release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentBookmarkParentId = -1;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    NSInteger count = [[folio bookmarksForParent:self.currentBookmarkParentId] count];
    
    if (self.currentBookmarkParentId >= 0)
    {
        count++;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell.selectedBackgroundView = self.selectedBackgroundView;
    }
    
    int selectedIndex = (int)indexPath.row;
    
    // Configure the cell...
    if (self.currentBookmarkParentId >= 0)
    {
        selectedIndex--;
    }
    
    if (selectedIndex >= 0)
    {
        NSArray * bks = [folio bookmarksForParent:self.currentBookmarkParentId];
        VBBookmark * bk = [bks objectAtIndex:selectedIndex];
        if (bk.recordId < 0)
        {
            cell.imageView.image = [self.skinManager imageForName:@"cont_folder"];
            cell.textLabel.text = [NSString stringWithFormat:@"[%@]", bk.name];
        }
        else
        {
            cell.imageView.image = [self.skinManager imageForName:@"cont_bkmk_open"];
            cell.textLabel.text = bk.name;
        }
    }
    else
    {
        cell.textLabel.text = @"[...]";
        cell.imageView.image = [self.skinManager imageForName:@"cont_folder"];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * bks = [folio bookmarksForParent:self.currentBookmarkParentId];
    int selIndex = (int)indexPath.row;
    if (self.currentBookmarkParentId >= 0)
        selIndex--;
    if (selIndex < 0)
    {
        VBBookmark * bk = [folio bookmarkWithId:self.currentBookmarkParentId];
        if (bk != nil)
        {
            self.currentBookmarkParentId = bk.parentId;
            [self.tableView reloadData];
        }
        self.updateButton.alpha = 0.5;
        self.updateButton.enabled = NO;
    }
    else
    {
        self.selectedBookmarkIndex = selIndex;
        VBBookmark * bk = [bks objectAtIndex:selIndex];
        if (bk.recordId < 0)
        {
            self.currentBookmarkParentId = bk.ID;
            [self.tableView reloadData];
            self.updateButton.alpha = 0.5;
            self.updateButton.enabled = NO;
        }
        else
        {
            self.updateButton.alpha = 1.0;
            self.updateButton.enabled = YES;
        }
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedBookmarkIndex = -1;
    self.updateButton.alpha = 0.5;
    self.updateButton.enabled = NO;
}

@end
