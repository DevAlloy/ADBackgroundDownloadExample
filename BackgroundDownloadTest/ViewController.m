//
//  ViewController.m
//  BackgroundDownloadTest
//
//  Created by Tsyganov Stanislav on 10.01.14.
//  Copyright (c) 2014 Tsyganov Stanislav. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  [self backgroundSession];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSURLSession *)backgroundSession{
  static NSURLSession *session = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSLog(@"create new session");
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.dev.BackgroundDownloadTest.BackgroundSession"];
    [config setAllowsCellularAccess:YES];
    session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
  });
  return session;
}

- (IBAction)startDownload:(id)sender {
  
  if (self.downloadTask) return;
  [self.imageView setImage:nil];
  [self.progressView setHidden:NO];
  [self.progressView setProgress:0.0];
  self.downloadTask = [[self backgroundSession] downloadTaskWithURL:[NSURL URLWithString:@"https://discussions.apple.com/servlet/JiveServlet/showImage/2-20930244-204399/iPhone%2B5%2BProblem2.jpg"]];
  
  [self.downloadTask resume];
  
}

- (IBAction)crash:(id)sender {
  int a[0];
  a[1]++;
}

- (void)callCompletionHandlerIfFinished
{
  NSLog(@"call completion handler");
  [[self backgroundSession] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
    NSUInteger count = [dataTasks count] + [uploadTasks count] + [downloadTasks count];
    if (count == 0) {
      NSLog(@"all tasks ended");
      AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
      if (appDelegate.backgroundSessionCompletionHandler == nil) return;
      
      void (^comletionHandler)() = appDelegate.backgroundSessionCompletionHandler;
      appDelegate.backgroundSessionCompletionHandler = nil;
      comletionHandler();
    }
  }];
}

#pragma mark - NSURLSession deleagte
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
  if (error) {
    NSLog(@"error: %@ - %@", task, error);
  } else {
    NSLog(@"success: %@", task);
  }
  self.downloadTask = nil;
  [self callCompletionHandlerIfFinished];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
  double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
  NSLog(@"download: %@ progress: %f", downloadTask, progress);
  dispatch_async(dispatch_get_main_queue(), ^{
    self.progressView.progress = progress;
  });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
  NSLog(@"did finish downloading");
  
  // We've successfully finished the download. Let's save the file
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
  NSURL *documentsDirectory = URLs[0];
  
  NSURL *destinationPath = [documentsDirectory URLByAppendingPathComponent:[location lastPathComponent]];
  NSError *error;
  
  // Make sure we overwrite anything that's already there
  [fileManager removeItemAtURL:destinationPath error:NULL];
  BOOL success = [fileManager copyItemAtURL:location toURL:destinationPath error:&error];
  
  if (success) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.imageView.image = [UIImage imageWithContentsOfFile:[destinationPath path]];
      [self.progressView setHidden:YES];
    });
  }
}

@end
