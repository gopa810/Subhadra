//
//  VCHitsDelegate.h
//  VedabaseB
//
//  Created by Peter Kollath on 23/08/14.
//
//

#import <Foundation/Foundation.h>

@class VCHits2;

@protocol VCHitsDelegate <NSObject>

-(void)hitsBar:(VCHits2 *)controller shouldHide:(BOOL)hide;

-(void)insertViewController:(UIViewController *)controller
                   fromSide:(CGSize)orientation;
-(void)insertViewController:(UIViewController *)controller
                   withDiff:(CGFloat)ratio;

@end
