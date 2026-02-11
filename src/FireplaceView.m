#import <AVFoundation/AVFoundation.h>
#import <ScreenSaver/ScreenSaver.h>

@interface FireplaceView : ScreenSaverView
@end

@implementation FireplaceView {
    AVPlayer *_player;
    AVPlayerLayer *_playerLayer;
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (!self) {
        return nil;
    }

    self.animationTimeInterval = 1.0 / 30.0;
    self.wantsLayer = YES;
    self.layer = [CALayer layer];
    self.layer.backgroundColor = NSColor.blackColor.CGColor;

    NSURL *videoURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"fireplace" withExtension:@"mp4"];
    if (videoURL == nil) {
        return self;
    }

    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoURL];
    _player = [AVPlayer playerWithPlayerItem:item];
    _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    _player.muted = YES;

    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _playerLayer.frame = self.bounds;
    [self.layer addSublayer:_playerLayer];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loopVideo:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:item];

    return self;
}

- (void)loopVideo:(NSNotification *)notification {
    if (_player == nil) {
        return;
    }

    [_player seekToTime:kCMTimeZero
        toleranceBefore:kCMTimeZero
         toleranceAfter:kCMTimeZero
      completionHandler:^(BOOL finished) {
          if (finished) {
              [self->_player play];
          }
      }];
}

- (void)startAnimation {
    [super startAnimation];
    [_player play];
}

- (void)stopAnimation {
    [_player pause];
    [super stopAnimation];
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    _playerLayer.frame = NSMakeRect(0, 0, newSize.width, newSize.height);
}

- (BOOL)hasConfigureSheet {
    return NO;
}

- (NSWindow *)configureSheet {
    return nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
