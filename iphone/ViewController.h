//
//  ViewController.h
//  iphone
//
//  Created by Liang Shi on 11-11-19.
//  Copyright (c) 2011 University of Alberta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReaderOverlayView.h"
#import "ZBarReaderViewController.h"
#import <AVFoundation/AVAudioPlayer.h>

@interface ViewController : UIViewController <ZBarReaderDelegate> {
    
    NSMutableArray *listItems;
    ZBarReaderViewController *reader;
    ReaderOverlayView *overlay;
    AVAudioPlayer *beep;
    UITableView *tableView;
    
    IBOutlet UIWebView *webView;
    
//    IBOutlet UIWindow *window;
//    IBOutlet UINavigationController *navigationController;
}

- (IBAction)showInfo:(id)sender;
@property (nonatomic, retain) NSMutableArray *listItems;
@property (nonatomic, retain) ZBarReaderViewController *reader;
@property (nonatomic, retain) ReaderOverlayView *overlay;
@property (nonatomic, retain) UIWebView *webView;

//@property (nonatomic, retain) IBOutlet UIWindow *window;
//@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
- (void)initReader:(NSInteger)src;

@end
