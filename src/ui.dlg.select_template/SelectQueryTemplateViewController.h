//
//  SelectQueryTemplateViewController.h
//  VedabaseB
//
//  Created by Peter Kollath on 1/6/14.
//
//

#import <UIKit/UIKit.h>
#import "VBDialogController.h"

@interface SelectQueryTemplateViewController : VBDialogController <UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) id delegateSearch;

@property (retain, nonatomic) IBOutlet UIView *partView;

@property (retain, nonatomic) IBOutlet UIView *shadeView;

@property (retain, nonatomic) IBOutlet UITableView *tableListView;

@property (retain, nonatomic) NSMutableArray * templates;
@property (retain, nonatomic) IBOutlet UIButton *btnAccept;
@property (assign) NSInteger selectedTemplateIndex;


+(SelectQueryTemplateViewController *)sharedDialog;




@end
