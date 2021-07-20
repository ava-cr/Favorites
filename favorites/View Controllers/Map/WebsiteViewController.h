//
//  WebsiteViewController.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/19/21.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebsiteViewController : UIViewController
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (nonatomic, strong) NSURL *url;

@end

NS_ASSUME_NONNULL_END
