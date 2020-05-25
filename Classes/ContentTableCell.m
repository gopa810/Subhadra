//
//  ContentTableCell.m
//  VedabaseB
//
//  Created by Peter Kollath on 20/09/14.
//
//

#import "ContentTableCell.h"
#import "ContentTableItemView.h"
#import "VBSkinManager.h"

@implementation ContentTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier skinManager:(VBSkinManager *)skinManager
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGRect frame = self.contentView.bounds;
        frame.origin.x += frame.size.width/12.0;
        frame.size.width *= 5.0 / 6.0;
        self.specView = [[ContentTableItemView alloc] initWithFrame:frame];
        self.specView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.specView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.specView];
        
        UIView * selView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        selView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        selView.backgroundColor = [skinManager colorForName:@"bodyBackground"];
        self.selectedBackgroundView = selView;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setData:(CIBase *)data
{
    self.specView.data = data;
    self->_data = data;
}

@end
