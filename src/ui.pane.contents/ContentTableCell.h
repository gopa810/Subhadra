//
//  ContentTableCell.h
//  VedabaseB
//
//  Created by Peter Kollath on 20/09/14.
//
//

#import <UIKit/UIKit.h>

@class CIBase;
@class ContentTableItemView;
@class VBSkinManager;

@interface ContentTableCell : UITableViewCell


@property ContentTableItemView * specView;
@property (nonatomic) CIBase * data;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier skinManager:(VBSkinManager *)skinManager;

@end
