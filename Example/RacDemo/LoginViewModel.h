//
//  LoginViewModel.h
//  RacDemo_Example
//
//  Created by 张晓龙 on 2021/1/9.
//  Copyright © 2021 176840964. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewModel : NSObject

@property (nonatomic, copy) NSString *iconUrlStr;
@property (nonatomic, copy) NSString *userNameStr;
@property (nonatomic, copy) NSString *passwordStr;
@property (nonatomic, strong) RACSignal *loginEnableSignal;
@property (nonatomic, strong) RACSubject *statusSubject;
@property (nonatomic, strong) RACCommand *loginCommand;

@end

NS_ASSUME_NONNULL_END
