//
//  LoginViewController.m
//  RacDemo_Example
//
//  Created by 张晓龙 on 2021/1/9.
//  Copyright © 2021 176840964. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginViewModel.h"

@interface LoginViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UITextField *userNameTF;
@property (nonatomic, weak) IBOutlet UITextField *passwordTF;
@property (nonatomic, weak) IBOutlet UILabel *tipLab;
@property (nonatomic, weak) IBOutlet UIButton *loginBtn;

@property (nonatomic, strong) LoginViewModel *viewModel;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.viewModel = [[LoginViewModel alloc] init];
    
    [self bindViewModel];
}

- (void)bindViewModel {
    @weakify(self);
    RAC(self.viewModel, userNameStr) = self.userNameTF.rac_textSignal;
    RAC(self.viewModel, passwordStr) = self.passwordTF.rac_textSignal;
    
    RAC(self.tipLab, text) = self.viewModel.statusSubject;
    RAC(self.loginBtn, enabled) = self.viewModel.loginEnableSignal;
    [self.viewModel.loginEnableSignal subscribeNext:^(NSNumber *isEnable) {
        @strongify(self);
        UIColor *bgColor = (isEnable.integerValue == 0) ? UIColor.lightGrayColor : UIColor.blueColor;
        self.loginBtn.backgroundColor = bgColor;
    }];
    
    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self.viewModel.loginCommand execute:@"登录"];
    }];
    
    [RACObserve(self.viewModel, iconUrlStr) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.iconImageView.image = [UIImage imageNamed:x];
    }];
    
}

@end
