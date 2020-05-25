//
//  SelectUserStringDelegate.h
//  VedabaseB
//
//  Created by Peter Kollath on 21/11/14.
//
//

@protocol SelectUserStringDelegate <NSObject>

-(void)userHasSelectedItem:(NSDictionary *)item inDialog:(NSString *)tag userInfo:(NSDictionary *)userInfo;

@end
