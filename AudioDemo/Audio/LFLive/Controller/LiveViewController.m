//
//  LiveViewController.m
//  AudioDemo
//
//  Created by 朱志佳 on 2019/6/5.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "LiveViewController.h"
#import "LiveManager.h"

@interface LiveViewController ()

@property (nonatomic,strong) UIView *preView;

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"直播页";
}

- (IBAction)start:(id)sender {
    @weakify(self)
    [LiveManager requestAccessForVideoCompletionHandler:^(BOOL granted) {
        @strongify(self)
        if (!granted) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"没有开启视频访问权限" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:^{
            }];
            
            return ;
        }
    }];
    [LiveManager requestAccessForAudioCompletionHandler:^(BOOL granted) {
        @strongify(self)
        if (!granted) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"没有开启音频访问权限" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:^{
            }];
        
            return;
        }
    }];
    
    [self.view addSubview:self.preView];
    [[LiveManager sharedmanager] startWithPreView:self.preView];
}
- (IBAction)stop:(id)sender {
    [[LiveManager sharedmanager] stop];
}
- (IBAction)changeOnBeauty:(id)sender {
    [[LiveManager sharedmanager] changeOnBeaty];
}
- (IBAction)changeOnCamera:(id)sender {
    [[LiveManager sharedmanager] changeOnCamera];
}

- (UIView *)preView
{
    if (!_preView) {
        UIView *preView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        preView.bottom = self.view.bottom;
        _preView = preView;
    }
    return _preView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
