//
//  ViewController.m
//  ImageTest
//
//  Created by Gavin Xiang on 2021/4/19.
//

#import "ViewController.h"
#import "ImageTest-Swift.h"
#import "UIImageCategories.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *iv;

@property (nonatomic, assign) NSInteger sampleIndex;

@property (nonatomic, assign) BOOL slazzered;

@property (nonatomic, assign) BOOL bordered;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectZero];
    iv.layer.borderColor = [UIColor redColor].CGColor;
    iv.layer.borderWidth = 0.5;
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:iv];
    
//    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
//    animation.fromValue = @(0);
//    animation.toValue = @(2 * M_PI);
//    animation.repeatCount = INFINITY;
//    animation.duration = 5.0;
//
//    [iv.layer addAnimation:animation forKey:@"rotation"];
//
//    CATransform3D transform = CATransform3DIdentity;
//    transform.m34 = 1.0 / 500.0;
//    iv.layer.transform = transform;

//    CGSize shadowOffset = CGSizeMake(5, 5);
//    CGFloat shadowRadius = 4.0f;
//    [iv.layer setShadowColor:[[UIColor colorWithWhite:0 alpha:0.8] CGColor]];
//    [iv.layer setShadowRadius:shadowRadius];
//    [iv.layer setShadowOffset:shadowOffset];
//    [iv.layer setShadowOpacity:1.0f];
    
//    CGFloat shadowBlur = 20.f;
//    CGRect shadowRect = CGRectInset(iv.bounds, 50, 50);
//    iv.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowRect].CGPath;
//    UIBezierPath *shadowPath = [resized shapeBezierPathWithBlur:shadowBlur offset:10 scale:3];
//    iv.layer.shadowPath = shadowPath.CGPath;
    
    _iv = iv;
    
    [self resetImageWithIndex:self.sampleIndex];
}

- (NSArray<NSString *> *)sampleImageNames {
    return @[@"beach",@"girl",@"gougou"];
}

typedef void (^SampleImageBlock)(BOOL, UIImage * _Nullable);

- (void)slazzerImage:(UIImage *)originalImg completion:(SampleImageBlock)completion {
#if TARGET_OS_SIMULATOR || TARGET_OS_MACCATALYST || TARGET_OS_TV || TARGET_OS_OSX
    NSLog(@"[WARNING] Please use iPhone/iPad device to run project!");
#else
    if (@available(iOS 17.0, *)) {
        [self showToast];
        [Timestamp printTimestamp];
        [ForegroundObjectFilter applyVisualEffectCroppedImageDataTo:UIImagePNGRepresentation(self.iv.image) croppedToInstancesExtent:NO result:^(NSData * _Nullable imageData) {
            [Timestamp printTimestamp];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideToast];
                if (imageData.length > 0) {
                    UIImage *slazzerImage = [UIImage imageWithData:imageData];
                    if (completion) {
                        completion(YES, slazzerImage);
                    }
                } else {
                    if (completion) {
                        completion(NO, nil);
                    }
                }
            });
        }];
    } else {
        // Fallback on earlier versions
        NSLog(@"Vision is iOS 17.0 only");
        if (completion) {
            completion(NO, nil);
        }
    }
#endif
}

- (void)renderImageBorderPicture:(UIImage *)slazzerImg completion:(SampleImageBlock)completion {
    [self showToast];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIColor *shadowColor = [UIColor colorWithWhite:0 alpha:0.4];
        CGFloat shadowBlur = 20.f;
        CGSize shadowOffset = CGSizeMake(5, 5);
        NSLog(@"render==begin==%zu==%zu", CGImageGetWidth(slazzerImg.CGImage), CGImageGetHeight(slazzerImg.CGImage));
        [Timestamp printTimestamp];
    //    UIImage *imageWithShadow = [resized withShadowWithBlur:shadowBlur offset:shadowOffset color:shadowColor];
    //    UIImage *gradientImage = [resized createGradientRoundedWithTintColor:[UIColor blueColor]];
        UIImage *imageWithShadow2 = [slazzerImg withOnlyShadowWithBlur:shadowBlur offset:shadowOffset color:shadowColor];
        
        CGSize destinateSize = CGSizeZero;
        if (imageWithShadow2.size.width > imageWithShadow2.size.height) {
            destinateSize = CGSizeMake(1000, 1000 * imageWithShadow2.size.height / imageWithShadow2.size.width);
        } else {
            destinateSize = CGSizeMake(1000 * imageWithShadow2.size.width / imageWithShadow2.size.height, 1000);
        }
        NSLog(@"original==%zu==%zu", CGImageGetWidth(imageWithShadow2.CGImage), CGImageGetHeight(imageWithShadow2.CGImage));
        UIImage *resized = [imageWithShadow2 resizedImage:destinateSize interpolationQuality:kCGInterpolationHigh];
        NSLog(@"resized==%zu==%zu", CGImageGetWidth(resized.CGImage), CGImageGetHeight(resized.CGImage));
        
        NSLog(@"render==end==%zu==%zu", CGImageGetWidth(resized.CGImage), CGImageGetHeight(resized.CGImage));
        [Timestamp printTimestamp];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideToast];
            if (completion) {
                completion(YES, resized);
            }
        });
    });
}

- (void)renderImageBorderPictureV2:(UIImage *)slazzerImg completion:(SampleImageBlock)completion {
    [self showToast];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIColor *shadowColor = [UIColor colorWithWhite:0 alpha:0.4];
        CGFloat shadowBlur = 20.f;
        CGSize shadowOffset = CGSizeMake(5, 5);
        NSLog(@"render==begin==%zu==%zu", CGImageGetWidth(slazzerImg.CGImage), CGImageGetHeight(slazzerImg.CGImage));
        [Timestamp printTimestamp];
    //    UIImage *imageWithShadow = [resized withShadowWithBlur:shadowBlur offset:shadowOffset color:shadowColor];
    //    UIImage *gradientImage = [resized createGradientRoundedWithTintColor:[UIColor blueColor]];
        UIImage *imageWithShadow2 = [slazzerImg shadowSlazzerPhotoWithBlur:shadowBlur offset:shadowOffset color:shadowColor];
        
        CGSize destinateSize = CGSizeZero;
        if (imageWithShadow2.size.width > imageWithShadow2.size.height) {
            destinateSize = CGSizeMake(1000, 1000 * imageWithShadow2.size.height / imageWithShadow2.size.width);
        } else {
            destinateSize = CGSizeMake(1000 * imageWithShadow2.size.width / imageWithShadow2.size.height, 1000);
        }
        NSLog(@"original==%zu==%zu", CGImageGetWidth(imageWithShadow2.CGImage), CGImageGetHeight(imageWithShadow2.CGImage));
        UIImage *resized = [imageWithShadow2 resizedImage:destinateSize interpolationQuality:kCGInterpolationHigh];
        NSLog(@"resized==%zu==%zu", CGImageGetWidth(resized.CGImage), CGImageGetHeight(resized.CGImage));
        
        NSLog(@"render==end==%zu==%zu", CGImageGetWidth(resized.CGImage), CGImageGetHeight(resized.CGImage));
        [Timestamp printTimestamp];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideToast];
            if (completion) {
                completion(YES, resized);
            }
        });
    });
}

- (void)resetImageWithIndex:(NSInteger)index {
    NSArray *sampleImageNames = self.sampleImageNames;
    if (index >= sampleImageNames.count) {
        index = 0;
    }
    NSString *imageName = sampleImageNames[index];
    UIImage *original = [UIImage imageNamed:imageName];
    [self resetImage:original];
    self.sampleIndex = index;
}

- (void)resetImage:(UIImage *)original {
    if (original.size.width == 0 || original.size.height == 0) {
        NSLog(@"[WARNING] image not exists!");
        return;
    }
    self.slazzered = NO;
    self.bordered = NO;
    self.iv.backgroundColor = UIColor.whiteColor;
    
    CGFloat ivWidth = self.view.bounds.size.width;
    CGSize destinateSize = CGSizeZero;
    if (original.size.width > original.size.height) {
        destinateSize = CGSizeMake(1000, 1000 * original.size.height / original.size.width);
    } else {
        destinateSize = CGSizeMake(1000 * original.size.width / original.size.height, 1000);
    }
    NSLog(@"original==%zu==%zu", CGImageGetWidth(original.CGImage), CGImageGetHeight(original.CGImage));
    UIImage *resized = [original resizedImage:destinateSize interpolationQuality:kCGInterpolationHigh];
    NSLog(@"resized==%zu==%zu", CGImageGetWidth(resized.CGImage), CGImageGetHeight(resized.CGImage));
    self.iv.image = resized;
    
    CGSize imageSize = CGSizeMake(ivWidth, ivWidth * destinateSize.height / destinateSize.width);
    _iv.frame = (CGRect){CGPointZero, imageSize};
    _iv.center = self.view.center;
}

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        _indicator.hidesWhenStopped = YES;
        [self.view addSubview:_indicator];
        _indicator.center = self.view.center;
    }
    return _indicator;
}

- (void)showToast {
    [self.indicator startAnimating];
    self.view.userInteractionEnabled = NO;
}

- (void)hideToast {
    [self.indicator stopAnimating];
    self.view.userInteractionEnabled = YES;
}

#pragma mark - Actions
- (IBAction)nextBtnClicked:(id)sender {
    NSLog(@"%s[%d]", __FUNCTION__, __LINE__);
    [self resetImageWithIndex:++self.sampleIndex];
}

- (IBAction)slazzerBtnClicked:(id)sender {
    NSLog(@"%s[%d]", __FUNCTION__, __LINE__);
    self.bordered = NO;
    if (self.slazzered) {
        return;
    }
    self.iv.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
    __weak __typeof(self) weakSelf = self;
    [self slazzerImage:self.iv.image completion:^(BOOL success, UIImage * _Nullable slazzerImage) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (success) {
            strongSelf.iv.image = slazzerImage;
            strongSelf.slazzered = YES;
        }
    }];
}

- (IBAction)borderBtnClicked:(id)sender {
    NSLog(@"%s[%d]", __FUNCTION__, __LINE__);
    self.slazzered = NO;
    if (self.bordered) {
        return;
    }
    self.iv.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
    __weak __typeof(self) weakSelf = self;
    [self renderImageBorderPicture:self.iv.image completion:^(BOOL success, UIImage * _Nullable borderImage) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (success) {
            strongSelf.iv.image = borderImage;
            strongSelf.bordered = YES;
        }
    }];
}

- (IBAction)borderV2BtnClicked:(id)sender {
    NSLog(@"%s[%d]", __FUNCTION__, __LINE__);
    self.slazzered = NO;
    if (self.bordered) {
        return;
    }
    self.iv.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
    __weak __typeof(self) weakSelf = self;
    [self renderImageBorderPictureV2:self.iv.image completion:^(BOOL success, UIImage * _Nullable borderImage) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (success) {
            strongSelf.iv.image = borderImage;
            strongSelf.bordered = YES;
        }
    }];
}

- (IBAction)resetBtnClicked:(id)sender {
    NSLog(@"%s[%d]", __FUNCTION__, __LINE__);
    [self resetImageWithIndex:self.sampleIndex];
}

@end
