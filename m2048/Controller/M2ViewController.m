//
//  M2ViewController.m
//  m2048
//
//  Created by Danqing on 3/16/14.
//  Copyright (c) 2014 Danqing. All rights reserved.
//

#import "M2ViewController.h"
#import "M2SettingsViewController.h"

#import "M2Scene.h"
#import "M2GameManager.h"
#import "M2ScoreView.h"
#import "M2Overlay.h"
#import "M2GridView.h"
#import <ShareSDK/ShareSDK.h>
#import "UIView+getImage.h"

@implementation M2ViewController {
  IBOutlet UIButton *_restartButton;
  IBOutlet UIButton *_settingsButton;
  IBOutlet UILabel *_targetScore;
  IBOutlet UILabel *_subtitle;
  IBOutlet M2ScoreView *_scoreView;
  IBOutlet M2ScoreView *_bestView;
    __weak IBOutlet UIButton *undoBtn;
  
  M2Scene *_scene;
  
  IBOutlet M2Overlay *_overlay;
  IBOutlet UIImageView *_overlayBackground;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self updateState];
  
  _bestView.score.text = [NSString stringWithFormat:@"%ld", (long)[Settings integerForKey:@"Best Score"]];
  
  _restartButton.layer.cornerRadius = [GSTATE cornerRadius];
  _restartButton.layer.masksToBounds = YES;
  
  _settingsButton.layer.cornerRadius = [GSTATE cornerRadius];
  _settingsButton.layer.masksToBounds = YES;
  
  _overlay.hidden = YES;
  _overlayBackground.hidden = YES;
  
  // Configure the view.
  SKView * skView = (SKView *)self.view;
  
  // Create and configure the scene.
  M2Scene * scene = [M2Scene sceneWithSize:skView.bounds.size];
  scene.scaleMode = SKSceneScaleModeAspectFill;
  
  // Present the scene.
  [skView presentScene:scene];
  [self updateScore:0];
  [scene startNewGame];
    self->undoBtn.enabled = YES;
  _scene = scene;
    _scene.delegate = self;

}

- (IBAction)undoIt:(id)sender {
    [_scene undo];
    [Flurry logEvent:@"Undo"];
}
- (IBAction)shareIt:(id)sender {
    UIImage *image = [self.view getImage];
    
    NSString *content = [NSString stringWithFormat:@"在%@模式中，我拿了%@/%@ 分，敢挑战我么? 我在玩2048扩展版，支持1024，2048，8196三种模式，还可以支持回撤哦!",_targetScore.text, _scoreView.score.text, _bestView.score.text];
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:content
                                                image:[ShareSDK pngImageWithImage:image]
                                                title:@"2048爆炸版"
                                                  url:@"https://itunes.apple.com/us/app/2048-delux/id904996577?ls=1&mt=8"
//                                                  url:@"d2048delux://ddd"
                                          description:content
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                    [Flurry logEvent:[NSString stringWithFormat:@"Shared to %@", [ShareSDK getClientNameWithType:type]]];
                                    
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}

- (void)updateState
{
  [_scoreView updateAppearance];
  [_bestView updateAppearance];
  
  _restartButton.backgroundColor = [GSTATE buttonColor];
  _restartButton.titleLabel.font = [UIFont fontWithName:[GSTATE boldFontName] size:14];
  
  _settingsButton.backgroundColor = [GSTATE buttonColor];
  _settingsButton.titleLabel.font = [UIFont fontWithName:[GSTATE boldFontName] size:14];
  
  _targetScore.textColor = [GSTATE buttonColor];
  
  long target = [GSTATE valueForLevel:GSTATE.winningLevel];
  
  if (target > 100000) {
    _targetScore.font = [UIFont fontWithName:[GSTATE boldFontName] size:34];
  } else if (target < 10000) {
    _targetScore.font = [UIFont fontWithName:[GSTATE boldFontName] size:42];
  } else {
    _targetScore.font = [UIFont fontWithName:[GSTATE boldFontName] size:40];
  }
  
  _targetScore.text = [NSString stringWithFormat:@"%ld", target];
  
  _subtitle.textColor = [GSTATE buttonColor];
  _subtitle.font = [UIFont fontWithName:[GSTATE regularFontName] size:14];
//    _subtitle.text = [NSString stringWithFormat:@"Join the numbers to get to %ld!", target];
    NSString *targetStr = NSLocalizedString(@"Join the numbers to get to %ld!", nil);
    _subtitle.text = [NSString stringWithFormat:targetStr, target];
  
  _overlay.message.font = [UIFont fontWithName:[GSTATE boldFontName] size:36];
  _overlay.keepPlaying.titleLabel.font = [UIFont fontWithName:[GSTATE boldFontName] size:17];
  _overlay.restartGame.titleLabel.font = [UIFont fontWithName:[GSTATE boldFontName] size:17];
  
  _overlay.message.textColor = [GSTATE buttonColor];
  [_overlay.keepPlaying setTitleColor:[GSTATE buttonColor] forState:UIControlStateNormal];
  [_overlay.restartGame setTitleColor:[GSTATE buttonColor] forState:UIControlStateNormal];
    
}


- (void)updateScore:(NSInteger)score
{
  _scoreView.score.text = [NSString stringWithFormat:@"%ld", (long)score];
  if ([Settings integerForKey:@"Best Score"] < score) {
    [Settings setInteger:score forKey:@"Best Score"];
    _bestView.score.text = [NSString stringWithFormat:@"%ld", (long)score];
  }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // Pause Sprite Kit. Otherwise the dismissal of the modal view would lag.
  ((SKView *)self.view).paused = YES;
}


- (IBAction)restart:(id)sender
{
  [self hideOverlay];
  [self updateScore:0];
  [_scene startNewGame];
}


- (IBAction)keepPlaying:(id)sender
{
  [self hideOverlay];
    if ([_overlay.keepPlaying.titleLabel.text isEqualToString:NSLocalizedString(@"Undo", nil)]) {
        [self undoIt:nil];
    }
}


- (IBAction)done:(UIStoryboardSegue *)segue
{
  ((SKView *)self.view).paused = NO;
  if (GSTATE.needRefresh) {
    [GSTATE loadGlobalState];
    [self updateState];
    [self updateScore:0];
    [_scene startNewGame];
  }
}


- (void)endGame:(BOOL)won
{
  _overlay.hidden = NO;
  _overlay.alpha = 0;
  _overlayBackground.hidden = NO;
  _overlayBackground.alpha = 0;
  
  if (!won) {
//    _overlay.keepPlaying.hidden = YES;
      [_overlay.keepPlaying setTitle:NSLocalizedString(@"Undo", nil) forState:UIControlStateNormal];
      _overlay.message.text = NSLocalizedString(@"Game Over", nil);//@"Game Over";
  } else {
      [_overlay.keepPlaying setTitle:NSLocalizedString(@"Keep Playing", nil) forState:UIControlStateNormal];
      _overlay.message.text = NSLocalizedString(@"You Win!", nil);//@"You Win!";
  }
  
  // Fake the overlay background as a mask on the board.
  _overlayBackground.image = [M2GridView gridImageWithOverlay];
  
  // Center the overlay in the board.
  CGFloat verticalOffset = [[UIScreen mainScreen] bounds].size.height - GSTATE.verticalOffset;
  NSInteger side = GSTATE.dimension * (GSTATE.tileSize + GSTATE.borderWidth) + GSTATE.borderWidth;
  _overlay.center = CGPointMake(GSTATE.horizontalOffset + side / 2, verticalOffset - side / 2);
  
  [UIView animateWithDuration:0.5 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    _overlay.alpha = 1;
    _overlayBackground.alpha = 1;
  } completion:^(BOOL finished) {
    // Freeze the current game.
    ((SKView *)self.view).paused = YES;
  }];
}


- (void)hideOverlay
{
  ((SKView *)self.view).paused = NO;
  if (!_overlay.hidden) {
    [UIView animateWithDuration:0.5 animations:^{
      _overlay.alpha = 0;
      _overlayBackground.alpha = 0;
    } completion:^(BOOL finished) {
      _overlay.hidden = YES;
      _overlayBackground.hidden = YES;
    }];
  }
}


- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

@end
