//
//  ViewController.h
//  XREdu
//
//  Created by senfang zhu on 2018/3/21.
//  Copyright © 2018年 xierui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController: UIViewController<UIWebViewDelegate>
{
    NSString *serverIP;
    UIWebView *webView;
    UIActivityIndicatorView *activityIndicator;
    
}

@end

