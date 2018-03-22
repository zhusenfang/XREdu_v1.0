//
//  ViewController.m
//  XREdu
//
//  Created by senfang zhu on 2018/3/21.
//  Copyright © 2018年 xierui. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarHidden =YES;
    webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [webView setDelegate:self];
    
    //NSString *path = [[NSBundle mainBundle]pathForResource:@"bg"ofType:@"jpg"];
    //webView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:path]];
    //webView.detectsPhoneNumbers = YES;//自动检测网页上的电话号码，单击可以拨打

    [self.view addSubview: webView];
    [self loadWebview];
    
    // NSLog(@"-----------test：%@-----------------",serverIP);
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)loadWebview
{
    serverIP = [self getServerIP];
    if([self isBlankString:serverIP])
    {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"wwwroot/html/set/bind_serverip.html" withExtension:nil];
        NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
        [webView loadRequest:request];
        //NSString *filepath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
        //NSString *htmlstring = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
        //NSURL *url = [[NSURL alloc]initWithString:filepath];
        //[webView loadHTMLString:htmlstring baseURL:url];
    }
    else
    {
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/apphome/weixin/wxjxt/applogin" ,serverIP]]];
        [webView loadRequest:request];
    }
    
}




-(NSString *)getServerIP
{
    NSUserDefaults *d= [NSUserDefaults standardUserDefaults];
    NSString *vser = [d valueForKey:@"serverip"];
    NSLog(@"-----------系统数据：%@-----------------",vser);
    
    return  vser;
}

-(BOOL)setServerIP:(NSString *)serverip
{
    if([self isBlankString:serverip]){return NO;}
    
    NSUserDefaults *d= [NSUserDefaults standardUserDefaults];
    [d setValue:serverip forKeyPath:@"serverip"];
    [d synchronize];
    return YES;
}

- (BOOL)isBlankString:(NSString *)aStr {
    if (!aStr) {
        return YES;
    }
    if ([aStr isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!aStr.length) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [aStr stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void) webViewDidStartLoad:(UIWebView *)webView
{
    //创建UIActivityIndicatorView背底半透明View
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [view setTag:108];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.5];
    [self.view addSubview:view];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:view.center];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [view addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
    NSLog(@"webViewDidStartLoad");
}
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
    NSLog(@"webViewDidFinishLoad");
    
    
    
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"setserverip"]=^(){
        NSArray *args = [JSContext currentArguments];
        JSValue *j = args[0];
        
        if([self setServerIP:j.toString] == YES)
        {
            NSString *js = [NSString stringWithFormat:@"alert('%@')",@"设置成功"];
            [webView stringByEvaluatingJavaScriptFromString:js];
            [self loadWebview];
        }
        else
        {
            NSString *js = [NSString stringWithFormat:@"alert('%@')",@"设置失败"];
            [webView stringByEvaluatingJavaScriptFromString:js];
        }
        
        //UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"方式二" message:@"弹出" delegate:self cancelButtonTitle:@"收到" otherButtonTitles:nil];
        //[av show];
        //for(JSValue *j in args){
        //    NSLog(@"%@",j.toString);
        //}
        //[self setServerIP:[args[0].toString]];
        
        
        //NSLog(@"------------share---------------");
    };
    context[@"getserverip"]=^(){
        NSString *ip = [self getServerIP];
        
        NSString *js = [NSString stringWithFormat:@"settoip('%@')",ip];
        [webView stringByEvaluatingJavaScriptFromString:js];
    };
    context[@"initsystem"]=^(){
        [self loadWebview];
    };
    
    
    context[@"loadset"]=^(){
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"wwwroot/html/set/bind_serverip.html" withExtension:nil];
        NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
        [webView loadRequest:request];
    };
    
    
}
- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityIndicator stopAnimating];
    UIView *view = (UIView*)[self.view viewWithTag:108];
    [view removeFromSuperview];
    NSLog(@"didFailLoadWithError:%@", error);
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
      //  NSString *currentURL= request.URL.absoluteString;
        //if([currentURL hasPrefix:@"tel:"]){
          //  currentURL = [currentURL stringByReplacingOccurrencesOfString:@"tel:" withString:@""];
            //[self dialPhoneNumber:currentURL];
    
    //[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",aPhoneNumber]]]];
        //}
        
        //NSLog(@"request:%@",[[request URL] absoluteString]);
        
    //}
    
    return YES;
    
}





@end
