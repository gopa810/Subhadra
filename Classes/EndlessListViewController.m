//
//  EndlessListViewController.m
//  VedabaseB
//
//  Created by Peter Kollath on 16/01/15.
//
//

#import "EndlessListViewController.h"
#import "EndlessParagraphViewCell.h"

@interface EndlessListViewController ()

@end

@implementation EndlessListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.selection = [FDSelectionContext new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return (NSInteger)[self.dataSource getRecordCount];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString * reuseId = @"endlessParaCell";
    EndlessParagraphViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    //NSLog(@"indexpath at %d", indexPath.row);
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[EndlessParagraphViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:reuseId];
        cell.backgroundColor = tableView.backgroundColor;
    }

    int recId = (int)indexPath.row;
    cell.record = [self.dataSource getRawRecord:recId];
    cell.notes = [self.dataSource recordNotesForRecord:recId];
    cell.drawer = self.drawer;
    cell.selection = self.selection;
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FDRecordBase * record = [self.dataSource getRawRecord:(int)indexPath.row];
    
    CGFloat width = tableView.frame.size.width - self.drawer.paddingLeft - self.drawer.paddingRight;
    //NSLog(@"VAL for indexpath %d, width %f", (int)indexPath.row, width);
    CGFloat height = [record validateForWidth:width];
    height = ceil(height);
    return height;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
