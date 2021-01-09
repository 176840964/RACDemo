//
//  DZViewController.m
//  RacDemo
//
//  Created by 176840964 on 01/01/2021.
//  Copyright (c) 2021 176840964. All rights reserved.
//

#import "DZViewController.h"
#import <ReactiveObjC.h>
#import <RACReturnSignal.h>

@interface DZViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, copy) NSString *nameStr;
@property (nonatomic, weak) IBOutlet UIImageView *genderImgView;
@property (nonatomic, weak) IBOutlet UISwitch *genderSwitch;

@end

@implementation DZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self demo];
}

- (void)multicastConnectionDemo {
    //创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        //发送信号
        NSLog(@"send");
        [subscriber sendNext:@"DZ"];
        //析构
        RACDisposable *disposable = [RACDisposable disposableWithBlock:^{
            NSLog(@"销毁了");
        }];
        return disposable;
    }];
    RACMulticastConnection *connection = [signal publish];
    //订阅
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"1：%@", x);
    }];
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"2：%@", x);
    }];
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"3：%@", x);
    }];
    [connection connect];
    
//    //订阅
//    [signal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"1：%@", x);
//    }];
//    [signal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"2：%@", x);
//    }];
//    [signal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"3：%@", x);
//    }];
}

#pragma mark - Subject
- (void)subjectDemo {
    RACSubject *subject = [RACSubject subject];
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    [subject sendNext:@"DZ"];
}

#pragma mark - Signal
- (void)signalDemo {
    //创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        //发送信号
        [subscriber sendNext:@"DZ"];
        //析构
        RACDisposable *disposable = [RACDisposable disposableWithBlock:^{
            NSLog(@"销毁了");
        }];
        return disposable;
    }];
    //订阅
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
}

#pragma mark - timeout
- (void)timeoutDemo {
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return nil;
    }] timeout:1 onScheduler:[RACScheduler currentScheduler]];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    } error:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];
}

#pragma mark - replay & retry
- (void)replayDemo {
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        return nil;
    }] replay];
    [signal subscribeNext:^(id x) {
        NSLog(@"第一个订阅者%@",x);
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"第二个订阅者%@",x);
    }];
}

- (void)retryDemo {
    __block int i = 0;
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (i == 5) {
            [subscriber sendNext:@1];
        }else{
            NSLog(@"接收到错误");
            [subscriber sendError:nil];
        }
        i++;
        return nil;
        
    }] retry] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    } error:^(NSError *error) {
        
    }];
}

#pragma mark - switchToLatest
- (void)switchToLatestDemo {
    RACSubject *signalOfSignals = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];
    [signalOfSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [signalOfSignals sendNext:signal];
    [signal sendNext:@1];
    [signal sendNext:@2];
}

#pragma mark - map
- (void)mapDemo {
    RACSubject *subject = [RACSubject subject];
    [[subject map:^id _Nullable(id  _Nullable value) {
        return value = @([value integerValue] + 1);
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"map:%@", x);
    }];
    
    
    RACSubject *signalOfSignals = [RACSubject subject];
    [[signalOfSignals flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return value;
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"flattenMap:%@", x);
    }];
    
    [signalOfSignals sendNext:subject];

    [subject sendNext:@1];
    [subject sendNext:@2];
}

#pragma mark - bind
- (void)bindDemo {
    RACSubject *subject = [RACSubject subject];
    [[subject bind:^RACSignalBindBlock _Nonnull {
        return ^RACSignal * (id value, BOOL *stop) {
            return [RACReturnSignal return:[NSString stringWithFormat:@"（输出:%@）",value]];
        };
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"bind:%@", x);
    }];
    
    [subject sendNext:@1];
}

#pragma mark - concat
- (void)concatDemo {
//    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//        [subscriber sendNext:@1];
//        [subscriber sendCompleted];
//        return nil;
//    }];
//    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//        [subscriber sendNext:@2];
//        [subscriber sendCompleted];
//        return nil;
//    }];
//    [[signal1 concat:signal2] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"concat:%@", x);
//    }];
    
    RACSubject *subject1 = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    [[subject1 concat:subject2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"concat:%@", x);
    }];
    [subject1 sendNext:@1];
    [subject1 sendNext:@2];
    [subject1 sendCompleted];
    [subject2 sendNext:@3];
}

#pragma mark - then
- (void)thenDemo {
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@1];
        //要调用完成
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal * _Nonnull{
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@2];
            return nil;
        }];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"then:%@", x);
    }];
}

#pragma mark - merge
- (void)mergeDemo {
    RACSubject *subject1 = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    [[subject1 merge:subject2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"merge:%@", x);
    }];
    [subject1 sendNext:@1];
    [subject1 sendNext:@2];
    [subject2 sendNext:@3];
}

#pragma mark - zip
- (void)zipDemo {
    RACSubject *subject1 = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    [[subject1 zipWith:subject2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"zip:%@", x);
    }];
    [subject1 sendNext:@1];
    [subject1 sendNext:@2];
    [subject2 sendNext:@3];
//    [subject2 sendNext:@4];
}

#pragma mark - combineLatest
- (void)combineLatestDemo {
    RACSubject *subject1 = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    [[subject1 combineLatestWith:subject2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"combine:%@", x);
    }];
    
    [subject1 sendNext:@1];
    [subject2 sendNext:@2];
    [subject1 sendNext:@3];
}

- (void)combineReduceDemo {
    RACSubject *subject1 = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    RACSubject *subject3 = [RACSubject subject];
    RACSubject *reduceSubject = [RACSubject combineLatest:@[subject1, subject2, subject3] reduce:^(id value1, id value2, id value3){
        return [NSString stringWithFormat:@"%@-%@-%@", value1, value2, value3];
    }];
    [reduceSubject subscribeNext:^(id  _Nullable x) {
        NSLog(@"reduce:%@", x);
    }];
    [subject1 sendNext:@1];
    [subject1 sendNext:@2];
    
    [subject2 sendNext:@3];
    [subject2 sendNext:@4];
    
    [subject3 sendNext:@5];
    [subject3 sendNext:@6];
}

#pragma mark - filter
- (void)filterDemo {
    RACSubject *subject = [RACSubject subject];
    [[subject filter:^BOOL(id  _Nullable value) {
        if ([value isEqualToNumber:@2]) {
            return NO;
        } else {
            return YES;
        }
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"filter:%@", x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
}

#pragma mark - ignore
- (void)ignoreDemo {
    RACSubject *subject = [RACSubject subject];
    [[subject ignore:@1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"ignore:%@", x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
}

#pragma mark - distinctUnitChanged
- (void)distinctUnitChangedDemo {
    RACSubject *subject = [RACSubject subject];
    [[subject distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        NSLog(@"distinctUnitChanged:%@", x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@2];
    [subject sendNext:@3];
}

#pragma mark - skip
- (void)skipDemo {
    RACSubject *subject = [RACSubject subject];
    [[subject skip:1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"skip: %@", x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
}

#pragma mark - take
- (void)takeUntilDemo {
    RACSubject *subject1 = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    
    [[subject1 takeUntil:subject2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"takeUntil:%@", x);
    }];
    [subject1 sendNext:@"subject1 111"];
    [subject1 sendNext:@"subject1 222"];
    [subject2 sendNext:@"subject2"];
//    [subject2 sendCompleted];
    [subject1 sendNext:@"subject1 333"];
}

- (void)takeLastDemo {
    RACSubject *subject = [RACSubject subject];
    [[subject takeLast:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"takeLast:%@", x);
    }];
    
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    [subject sendCompleted];//一定要调用completed
}

- (void)takeDemo {
//    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//        [subscriber sendNext:@1];
//        [subscriber sendNext:@2];
//        [subscriber sendNext:@3];
//
//        return nil;
//    }];
//
//    [[signal take:2] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@", x);
//    }];
    
    RACSubject *subject = [RACSubject subject];
    [[subject take:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"take: %@", x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
}

#pragma mark - switch image
- (void)demo {
    self.genderImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gender%@", @(self.genderSwitch.on)]];
    @weakify(self)
    [[self.genderSwitch rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        UISwitch *sw = x;
        self.genderImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gender%@", @(sw.on)]];
    }];
}

#pragma mark - gesture recognize
- (void)gestureRecognizerDemo {
    self.label.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [self.label addGestureRecognizer:tap];
    [tap.rac_gestureSignal subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        NSLog(@"rac gesture:%@", x);
    }];
}

#pragma mark - sequence
- (void)sequenceDemo {
    NSArray *arr = @[@"DZ", @"xz", @"ios"];
    NSMutableArray *muArr = [NSMutableArray arrayWithArray:arr];
    [muArr.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"rac arr:%@", x);
    }];
    [muArr addObject:@"NB"];
    
//    NSDictionary *dic = @{@"name": @"DZ", @"age": @(18)};
//    [dic.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"rac dic:%@", x);
//    }];
}

#pragma mark - button
- (void)buttonDemo {
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"rac button: %@", x);
    }];
}

#pragma mark - notification
- (void)notificationDemo {
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"rac notification: %@", x);
    }];
    
}

#pragma mark - delegate demo
- (void)delegateDemo {
    //设置代理别忘了写
    self.textField.delegate = self;
    [[self rac_signalForSelector:@selector(textFieldDidBeginEditing:) fromProtocol:@protocol(UITextFieldDelegate)] subscribeNext:^(RACTuple * _Nullable x) {
        NSLog(@"rac protocol: %@", x);
    }];
}

#pragma mark - KVO demo
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.nameStr = [NSString stringWithFormat:@"%@+", self.nameStr];
}

- (void)KVODemo {
    self.nameStr = @"DZ";
    
//    [self addObserver:self forKeyPath:@"nameStr" options:NSKeyValueObservingOptionNew context:NULL];
    
    [RACObserve(self, nameStr) subscribeNext:^(id  _Nullable x) {
        NSLog(@"RAC:nameStr:%@", x);
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"kvo:%@", change);
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
//    [self removeObserver:self forKeyPath:@"nameStr"];
}

@end
