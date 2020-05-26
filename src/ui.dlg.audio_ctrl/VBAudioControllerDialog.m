//
//  VBAudioControllerDialog.m
//  VedabaseB
//
//  Created by Peter Kollath on 04/11/14.
//
//

#import "VBAudioControllerDialog.h"
#import <AVFoundation/AVAudioPlayer.h>
#import "VBMainServant.h"

@interface VBAudioControllerDialog ()

@end

@implementation VBAudioControllerDialog

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btnBack.backgroundColor = [UIColor clearColor];
    self.btnBack.touchCommand = @"btnBack";
    self.btnBack.backgroundImage = [self.skinManager imageForName:@"audio_back"];
    
    self.btnFwd.backgroundColor = [UIColor clearColor];
    self.btnFwd.touchCommand = @"btnFwd";
    self.btnFwd.backgroundImage = [self.skinManager imageForName:@"audio_fwd"];
    
    self.btnPlay.backgroundColor = [UIColor clearColor];
    self.btnPlay.touchCommand = @"btnPausePlay";
    self.btnPlay.backgroundImage = [self.skinManager imageForName:@"audio_pause"];
    self.buttonPauseMode = 1;

    self.btnStop.backgroundColor = [UIColor clearColor];
    self.btnStop.touchCommand = @"btnStop";
    self.btnStop.backgroundImage = [self.skinManager imageForName:@"audio_stop"];
    
    self.backView.mainColor = [self.skinManager colorForName:@"liteGradientA"];
    self.backView.mainBottomColor = [self.skinManager colorForName:@"liteGradientB"];
    self.backView.sides = UIRectEdgeTop;
    
    self.timeBackView.mainColor = [self.skinManager colorForName:@"darkGradientA"];
    self.timeBackView.mainBottomColor = [self.skinManager colorForName:@"darkGradientB"];
    self.timeBackView.sides = UIRectEdgeNone;
    
    self.backView.backgroundColor = [self.skinManager colorForName:@"lite_papyrus"];
    self.timeBackView.backgroundColor = [self.skinManager colorForName:@"dark_papyrus"];
    self.view.backgroundColor = [UIColor clearColor];

    [self updateViewInfo:self];
}

-(void)updateViewInfo:(id)sender
{
    //NSLog(@"--- timer ------");
    AVAudioPlayer * player = [[self userInterfaceManager] audioPlayer];
    if (!player.playing)
    {
        //[[self userInterfaceManager] setAudioPlayer:nil];
        //player = nil;
    }
    
    if (player != nil)
    {
        int currentSecs = player.currentTime;
        int durSecs = player.duration;
        NSString * str = [NSString stringWithFormat:@"%02d:%02d / %02d:%02d", currentSecs/60, currentSecs%60, durSecs / 60, durSecs % 60];
        [self.timeLabel setText:str];
        [self.fileNameLabel setText: [self.delegate currentPlayObject]];
        [self performSelector:@selector(updateViewInfo:) withObject:self afterDelay:1.0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)onTabButtonPressed:(id)sender
{
    TGTouchArea * btn = (TGTouchArea *)sender;
    btn.backgroundColor = [UIColor whiteColor];
}

-(void)onTabButtonReleasedOut:(id)sender
{
    TGTouchArea * btn = (TGTouchArea *)sender;
    btn.backgroundColor = [UIColor clearColor];
}

-(void)onTabButtonReleased:(id)sender
{
    TGTouchArea * btn = (TGTouchArea *)sender;
    btn.backgroundColor = [UIColor clearColor];
    NSString * command = btn.touchCommand;
    AVAudioPlayer * player = [self.userInterfaceManager audioPlayer];

    //NSLog(@"user im: %p", self.userInterfaceManager);
    NSLog(@"player is: %p", player);
    if (player != nil)
    {
        if ([command isEqualToString:@"btnBack"])
        {
            [player stop];
            [self.delegate runSoundPrevious];
        }
        else if ([command isEqualToString:@"btnFwd"])
        {
            [player stop];
            [self.delegate runSound];
        }
        else if ([command isEqualToString:@"btnPausePlay"])
        {
            if (self.buttonPauseMode == 1)
            {
                [self.btnPlay setBackgroundImage: [self.skinManager imageForName:@"audio_play"]];
                [player pause];
                self.buttonPauseMode = 0;
            }
            else
            {
                [self.btnPlay setBackgroundImage: [self.skinManager imageForName:@"audio_pause"]];
                [player play];
                self.buttonPauseMode = 1;
            }
        }
        else if ([command isEqualToString:@"btnStop"])
        {
            [player stop];
            [self.delegate stopSound];
        }
    }
    else
    {
        if ([command isEqualToString:@"btnStop"])
        {
            [self.delegate stopSound];
        }
    }
}


@end
