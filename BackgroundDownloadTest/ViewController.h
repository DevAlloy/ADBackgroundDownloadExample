//
//  ViewController.h
//  BackgroundDownloadTest
//
//  Created by Tsyganov Stanislav on 10.01.14.
//  Copyright (c) 2014 Tsyganov Stanislav. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<NSURLSessionDownloadDelegate>
- (IBAction)startDownload:(id)sender;
- (IBAction)crash:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end
