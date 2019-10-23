//
//  ViewController.m
//  VaptchaH5
//
//  Created by GuoshikejiMM01 on 2019/10/23.
//  Copyright © 2019 GuoshikejiMM01. All rights reserved.
//

#import "ViewController.h"

//
#import <WebKit/WebKit.h>

@interface WKScriptMessageHandlerHelper : NSObject <WKScriptMessageHandler>

@property (nonatomic, weak) id <WKScriptMessageHandler> delegate;

- (instancetype)initWithDelegate:(id <WKScriptMessageHandler>)delegate;

@end

@implementation WKScriptMessageHandlerHelper

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end

@interface ViewController () <WKScriptMessageHandler,WKNavigationDelegate>

//
@property (nonnull, nonatomic, strong) WKWebView *webView;

//
@property (nonnull, nonatomic, strong) WKScriptMessageHandlerHelper *handlerHelper;

//
@property (nonnull, nonatomic, strong) UIAlertController *alertController;


@end

@implementation ViewController
{
    BOOL _passed;
}

//设置webView
- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        _webView.navigationDelegate = self;
        //js
        [_webView.configuration.userContentController addScriptMessageHandler:self.handlerHelper name:@"signal"];
        //
        [self.view addSubview:_webView];
        _webView.alpha = 0;
    }
    return _webView;
}

//设置helper
- (WKScriptMessageHandlerHelper *)handlerHelper {
    if (!_handlerHelper) {
        _handlerHelper = [[WKScriptMessageHandlerHelper alloc] initWithDelegate:self];
    }
    return _handlerHelper;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)buttonClickedAction:(UIButton *)sender {
    //
    _passed = NO;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://v.vaptcha.com/app/ios.html?vid=5b4d9c33a485e50410192331&lang=zh-CN&offline_server=https://www.vaptchadowntime.com/dometime"]]];
}


#pragma mark - WKNavigationDelegate
//
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    if (!_passed) {
        self.webView.alpha = 1;
    }
}


#pragma mark - WKScriptMessageHandler
//
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"signal"]) {
        id body = message.body;
        NSLog(@"%@",body);
        if ([body isKindOfClass:NSString.class]) {
            NSString *jsonString = body;
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            if (resultDic) {
                if ([resultDic[@"signal"] isEqualToString:@"pass"]) {
                    _passed = YES;
                }else {
                    _passed = NO;
                }
            }
            //
            if (_passed || self.webView.alpha) {
                NSString *sinal = resultDic[@"signal"];
                NSString *data = resultDic[@"data"];
                //
                self.alertController = [UIAlertController alertControllerWithTitle:sinal message:data preferredStyle:UIAlertControllerStyleAlert];
                [self.alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                [self presentViewController:self.alertController animated:YES completion:nil];
            }
        }
        self.webView.alpha = 0;
    }
}



- (void)dealloc {
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"signal"];
}


@end