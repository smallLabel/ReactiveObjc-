//
//  ViewController.m
//  ReactiveObjc使用
//
//  Created by smallLabel on 2018/7/12.
//  Copyright © 2018年 smallLabel. All rights reserved.
//

#import "ViewController.h"
#import "GlobalHeader.h"
#import <ReactiveObjC/RACReturnSignal.h>


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *acountText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (nonatomic, strong) id <RACSubscriber> subscriber;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self RACZipSignal];
    
//    [self RACMergeSignal];
    
//    [self RACConcat];
    
//    [self RACFlattenMap];
    
//    [self RACTraverse];
//    [self RACCommand];
//    [self RACBind];
//    [self combineSignal];
}

//组合信号
- (void)combineSignal {
    
    [_acountText.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        return !(value.length<5);
    }];
    
    RACSignal *signal = [RACSignal combineLatest:@[_acountText.rac_textSignal,  _passwordText.rac_textSignal] reduce:^id _Nonnull(NSString *acount, NSString *password){
        NSLog(@"%@  %@", acount, password);
        return @(acount.length && password.length);
    }];
    [signal subscribeNext:^(id  _Nullable x) {
        _loginBtn.enabled = [x boolValue];
    }];
    
   
}

//压缩信号 所有信号都发送内容时才会调用
- (void)RACZipSignal {
    RACSubject *subjectA = [RACSubject subject];
    RACSubject *subjectB = [RACSubject subject];
    
    RACSignal *signal = [subjectB zipWith:subjectA];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    [subjectA sendNext:@"hello"];
    [subjectB sendNext:@"world"];
    
}

//合并信号  任意一个信号发送都会触发
- (void)RACMergeSignal {
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    
    RACSignal *signal = [signalA merge:signalB];
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    [signalA sendNext:@"hello"];
    [signalB sendNext:@"world"];
}

- (void)RACSignal {
    //信号创建  订阅信号 发送信号  取消信号
    //创建信号
    RACSignal *signale = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        _subscriber = subscriber;
        //发送信号
        [subscriber sendNext:@"hello world"];
        RACDisposable *disposabel = [RACDisposable disposableWithBlock:^{
            NSLog(@"信号取消订阅或者发送完成");
        }];
        
        return disposabel;
    }];
    
    
    //订阅信号
    RACDisposable *disposable = [signale subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
        
    }];
    
    [disposable dispose];
}

//按照顺序执行
- (void)RACConcat {
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"A"];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"B"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    //会忽略掉第一个信号
    RACSignal *thenSignal = [signalA then:^RACSignal * _Nonnull{
        return signalB;
    }];
    
    [thenSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    
    //顺序执行信号
    RACSignal *concat = [signalB concat:signalA];
    [concat subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
}

- (void)RACFlattenMap {
    RACSubject *subject = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];
    [[subject flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        return value;
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    [subject sendNext:signal];
    [signal sendNext:@"hello"];
    
}

- (void)RACTraverse {
    //遍历
    //全都是异步的
    NSDictionary *dic = @{@"1":@"111", @"2":@"222"};
    
    [dic.rac_sequence.signal subscribeNext:^(RACTuple *  _Nullable x) {
        NSString *key = x[0];
        NSString *value = x[1];
        NSLog(@"%@  %@", key, value);
    }];
    
//    [dic.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@", x);
//        
//        NSLog(@"%@", [NSThread currentThread]);
//    }];
//    
//    [dic.rac_keySequence.signal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@", x);
//        NSLog(@"%@", [NSThread currentThread]);
//    }];
//    [dic.rac_valueSequence.signal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@", x);
//        NSLog(@"%@", [NSThread currentThread]);
//    }];
//    NSArray *arr = @[@"1", @"2"];
//    [arr.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@", x);
//    }];
}


- (void)RACBind {
    RACSubject *subject = [RACSubject subject];
    RACSignal *bindsignal = [subject bind:^RACSignalBindBlock _Nonnull{
        return ^RACSignal *(id value, BOOL *stop) {
            NSLog(@"value:%@", value);
            NSString *hellohahaha = @"worldhahaha";
            RACSignal *returnSignal = [RACReturnSignal return:hellohahaha];
            return returnSignal;
        };
    }];
    [bindsignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"x:%@", x);
    }];
    
    [subject sendNext:@"hello"];
    
   
    
    
}

- (void)RACCommand {
    //命令  必须执行才有效果
    RACCommand *command  = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"hello world"];
            return nil;
        }];
    }];
    //获取上一次执行的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    
    
    [command execute:@"1"];
}

- (void)RACSubject {
    //既可以创建信号也可以发送信号
    RACSubject *subject = [RACSubject subject];
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    [subject sendNext:@"hello world"];
}

- (void)RACReplySubject {
    //可以先发送信号在订阅信号
    RACReplaySubject *replySubject = [RACReplaySubject replaySubjectWithCapacity:10];
    [replySubject sendNext:@"1"];
    [replySubject subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
