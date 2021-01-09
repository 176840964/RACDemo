//
//  LoginViewModel.m
//  RacDemo_Example
//
//  Created by 张晓龙 on 2021/1/9.
//  Copyright © 2021 176840964. All rights reserved.
//

#import "LoginViewModel.h"

@interface LoginViewModel ()
@property (nonatomic, assign) BOOL isLogining;
@end

@implementation LoginViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.loginEnableSignal = [RACSignal combineLatest:@[RACObserve(self, userNameStr), RACObserve(self, passwordStr)] reduce:^id (NSString *account, NSString *password) {
            return @(account.length > 0 && password.length > 0);
        }];
        
        RAC(self, iconUrlStr) = [[[RACObserve(self, userNameStr) skip:1] map:^id _Nullable(id  _Nullable value) {
            NSLog(@"iconUrlStr:%@", value);
            return [NSString stringWithFormat:@"gender%@", value];
        }] distinctUntilChanged];
        
        self.statusSubject = [RACSubject subject];
        [self setupLoginCommand];
    }
    return self;
}

- (void)setupLoginCommand {
    @weakify(self)
    self.loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"%@", input);
        @strongify(self);
        return [self loginRequest];
    }];
    
    [[self.loginCommand.executionSignals switchToLatest] subscribeNext:^(id  _Nullable x) {
        NSLog(@"executionSignals: %@", NSThread.currentThread);
        @strongify(self);
        [self.statusSubject sendNext:@"登录成功"];
        self.isLogining = NO;
    }];
    
    [self.loginCommand.errors subscribeNext:^(NSError * _Nullable x) {
        NSLog(@"error = %@, currentThread = %@", x, NSThread.currentThread);
        @strongify(self);
        [self.statusSubject sendNext:@"登录失败"];
        self.isLogining = NO;
    }];
    
    [[self.loginCommand.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        NSLog(@"executing == %@",x);
        @strongify(self);
        if (x.boolValue) {
            [self statusLableAnimations];
        }
    }];
}

- (RACSignal *)loginRequest {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [NSThread sleepForTimeInterval:2];
            if ([self.userNameStr isEqualToString:@"123"] && [self.passwordStr isEqualToString:@"123"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [subscriber sendNext:@"login success"];
                    [subscriber sendCompleted];
                });
            } else {
                NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:4000 userInfo:@{@"error":@"login fail"}];
                [subscriber sendError:error];
            }
        });
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"析构了");
        }];
    }];
}

- (void)statusLableAnimations {
    self.isLogining = YES;
    __block int num = 0;
    @weakify(self);
    RACSignal *timeSignal = [[[RACSignal interval:0.5 onScheduler:[RACScheduler mainThreadScheduler]] map:^id _Nullable(NSDate * _Nullable value) {
        NSString *statusStr = @"登录中，请稍后";
        num += 1;
        switch (num % 3) {
            case 0:
                statusStr = @"登录中，请稍后.";
                break;
            case 1:
                statusStr = @"登录中，请稍后..";
                break;
            case 2:
                statusStr = @"登录中，请稍后...";
                break;
                
            default:
                break;
        }
        
        return statusStr;
    }] takeUntilBlock:^BOOL(id  _Nullable x) {
        @strongify(self);
        if (num > 10 || !self.isLogining) {
            return YES;
        }
        return NO;
    }];
    
    [timeSignal subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.statusSubject sendNext:x];
    }];
}

@end
