//
//  GetUserStringDelegate.h
//  VedabaseB
//
//  Created by Peter Kollath on 21/11/14.
//
//


@protocol GetUserStringDelegate <NSObject>

-(void)userHasEnteredString:(NSString *)str inDialog:(NSString *)tag userInfo:(NSDictionary *)userInfo;

@end

