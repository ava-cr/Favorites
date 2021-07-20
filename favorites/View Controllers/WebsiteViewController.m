//
//  WebsiteViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/19/21.
//

#import "WebsiteViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface WebsiteViewController ()

@end

@implementation WebsiteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD show];
    NSLog(@"%@", [self.url absoluteString]);
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:10.0];
    [SVProgressHUD dismiss];
    [self.webView loadRequest:request];
}

@end
