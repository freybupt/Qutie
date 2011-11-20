//
//  ViewController.m
//  iphone
//
//  Created by Liang Shi on 11-11-19.
//  Copyright (c) 2011 University of Alberta. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "WebViewController.h"

//@interface UIScrollView (extended)
//- (void)setAllowsRubberBanding:(BOOL)allowsRubberBanding;
//@end

//QTStates.eyes_open = 1;
//QTStates.eyes_closed = 2;
//QTStates.crying = 3;
//QTStates.eating = 4;
//QTStates.happy = 5;
//QTStates.winking = 6;
//QTStates.spooked = 7;
//QTStates.flying1 = 8;
//QTStates.flying2 = 9;
//QTStates.chew1 = 10;
//QTStates.chew2 = 11;
//QTStates.eat1 = 12;
//QTStates.eat2 = 13;


@implementation ViewController

@synthesize listItems, reader, overlay, webView, backButton;

//@synthesize window, navigationController;



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [(UIScrollView*)[webView.subviews objectAtIndex:0]	 setAllowsRubberBanding:NO];
	// Do any additional setup after loading the view, typically from a nib.
//        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"cavastest" ofType:@"html"]isDirectory:NO]]];
    QTstatus = @"index_chew1";
    linkResult = @"";
    soundTitle = @"dance";
    backButton.hidden = YES;
//    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    backButton.bounds = CGRectMake(0, 0, 60.0, 30.0);
//    [backButton setImage:[UIImage imageNamed:@"goBack.png"] forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    
    [self performSelector: @selector(playBeep)
               withObject: nil
               afterDelay: 0.001];

    webView.delegate = self;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:QTstatus ofType:@"html"]isDirectory:NO]]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([QTstatus isEqualToString:@"site"]) {
        //Create a URL object from scaned link
        NSURL *url = [NSURL URLWithString: linkResult];
        
        //URL Requst Object
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];     
        
        backButton.hidden = NO;
        
        //Load the request in the UIWebView.
        [webView loadRequest:requestObj];
    }
    else{
        
        backButton.hidden = YES;
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:QTstatus ofType:@"html"]isDirectory:NO]]];
    }
}


- (IBAction)goBack:(id)sender{
    QTstatus = @"index";
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:QTstatus ofType:@"html"]isDirectory:NO]]];
    backButton.hidden = YES;
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark -
- (void) initReader: (NSInteger) src
{
    
    if (src == UIImagePickerControllerSourceTypeCamera) {
        reader = [ZBarReaderViewController new];
        
        // use a custom overlay
        reader.showsZBarControls = NO;
        overlay = [ReaderOverlayView new];
        overlay.delegate = self;
    } else {
        reader = (id)[ZBarReaderController new];
    }
    
    reader.readerDelegate = self;
    
    ZBarImageScanner *scanner = reader.scanner;
    
    // show EAN variants as such
    [scanner setSymbology: ZBAR_UPCA
                   config: ZBAR_CFG_ENABLE
                       to: 1];
    [scanner setSymbology: ZBAR_UPCE
                   config: ZBAR_CFG_ENABLE
                       to: 1];
    [scanner setSymbology: ZBAR_ISBN13
                   config: ZBAR_CFG_ENABLE
                       to: 1];
    
    // disable rarely used i2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
}

#pragma mark -
#pragma mark ReaderOverlayDelegate
- (void)readerOverlayDidDismiss {
    //   [overlay willDisappear];
    [reader dismissModalViewControllerAnimated: YES];
}

#pragma mark -
#pragma mark ZBarReaderDelegate
- (void)imagePickerController: (UIImagePickerController*) picker didFinishPickingMediaWithInfo: (NSDictionary*) info {
    
    [self performSelector: @selector(playBeep)
               withObject: nil
               afterDelay: 0.001];
    
    
    UIImage *image = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    id <NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *sym = nil;
    for(sym in results)
        break;
    assert(sym);
    assert(image);
    if(!sym || !image)
        return;
    
    //  NSLog(@"type = %@", sym.type);
    NSLog(@"data = %@", sym.data);
    NSMutableString *outputString = [[NSMutableString alloc] init];
    [outputString appendString:@"<html><head><style>body,a {font-family: helvetica,arial,sans-serif; font-size:16px; line-height:1.6em; background-color:#000; color: #fdba31; text-decoration: none;}</style></head><body>"];
    
    
    NSArray *s = [sym.data componentsSeparatedByString:@"\n"];
    for (NSString *str in s) {
        NSLog(@"%@", str);
        if ([str length] >0) {
            
            [outputString appendFormat:@"%@<BR>",str];
        }
    }
    
    [outputString appendString:@"</body></html>"];
    
    NSString *resultString = sym.data;
    
    linkResult = resultString;
    
    QTstatus = @"index_spooky";
    
    //change status if qr code is defined
    if ([resultString isEqualToString:@"qutie_crying"]) {
        QTstatus = @"index_crying";
        soundTitle = @"cry2";
    }
    
    if ([resultString isEqualToString:@"qutie_winking"]) {
        QTstatus = @"index_winking";
    }
    if ([resultString isEqualToString:@"qutie_happy1"]) {
        QTstatus = @"index_happy1";
        soundTitle = @"dance";
    }
    if ([resultString isEqualToString:@"qutie_happy2"]) {
        QTstatus = @"index_happy2";
    }
    if ([resultString isEqualToString:@"qutie_flying1"]) {
        QTstatus = @"index_flying1";
    }
    if ([resultString isEqualToString:@"qutie_flying2"]) {
        QTstatus = @"index_flying2";
    }
    if ([resultString isEqualToString:@"qutie_eating1"]) {
        QTstatus = @"index_eating1";

    }
    if ([resultString isEqualToString:@"qutie_eating2"]) {
        QTstatus = @"index_eating2";
        
    }
    if ([resultString isEqualToString:@"qutie_chew1"]) {
        QTstatus = @"index_chew1";
    }
    if ([resultString isEqualToString:@"qutie_chew2"]) {
        QTstatus = @"index_chew2";
    }
    if ([resultString isEqualToString:@"qutie_spooky"]) {
        QTstatus = @"index_spooky";
        soundTitle = @"scream1";
    }
//    if ([resultString isEqualToString:@"qutie_drunk"]) {
//        QTstatus = @"index_drunk";
//    }
    if ([resultString isEqualToString:@"qutie_fly"]) {
        QTstatus = @"index_flying";
    }
     NSString *headerUrl = [resultString substringToIndex:4];
    if([headerUrl isEqualToString:@"http"]){
        QTstatus = @"site";
    }

//    [self performSelector: @selector(dismissCamera)
//               withObject: nil
//               afterDelay: 1.0];
    
    [self dismissCamera];
    
    //don't remove, for alert of link
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Got it!" message:resultString delegate:self cancelButtonTitle:nil otherButtonTitles:@"Feed it!", nil];
//    [alert show];
    
}

- (void)dismissCamera{
    [self dismissModalViewControllerAnimated: NO];

}
//- (void)webViewDidFinishLoad:(UIWebView *)wView {
//    NSString *someHTML = [wView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('box')[0]"];   
//    NSString *allHTML = [wView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
//    NSLog(@"someHTML: %@", someHTML);
//    NSLog(@"allHTML: %@", allHTML);
//    NSString *testString = @"http://www.google.com";
//    [webView stringByEvaluatingJavaScriptFromString:testString];
//    NSString* script = [NSString stringWithFormat:@"loadLink(%@);", testString];
//    [webView stringByEvaluatingJavaScriptFromString:script];
//}

- (void) initAudio {
    if(beep)
        return;
    NSError *error = nil;
    beep = [[AVAudioPlayer alloc]
            initWithContentsOfURL:
            [[NSBundle mainBundle]
             URLForResource: @"crunching"
             withExtension: @"wav"]
            error: &error];
    if(!beep)
        NSLog(@"ERROR loading sound: %@: %@",
              [error localizedDescription],
              [error localizedFailureReason]);
    else {
        beep.volume = .5f;
        [beep prepareToPlay];
    }
}

- (void) playBeep{
    if(!beep)
//        [self initAudio];
        if(beep)
            return;
    NSError *error = nil;
    beep = [[AVAudioPlayer alloc]
            initWithContentsOfURL:
            [[NSBundle mainBundle]
             URLForResource: soundTitle
             withExtension: @"wav"]
            error: &error];
    if(!beep)
        NSLog(@"ERROR loading sound: %@: %@",
              [error localizedDescription],
              [error localizedFailureReason]);
    else {
        beep.volume = .5f;
        [beep prepareToPlay];
    }

    [beep play];
}

- (NSString*)md5HexDigest:(NSString*)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}


- (IBAction)showInfo:(id)sender
{
    if(beep){
        [beep stop];
    }
    soundTitle = @"crunching";
    [self performSelector: @selector(playBeep)
               withObject: nil
               afterDelay: 0.005];
    // test plain image picker
    //    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    // //   imagePicker.delegate = self;
    //    imagePicker.allowsEditing = NO;
    //    imagePicker.showsCameraControls = NO;
    //    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //    [self presentModalViewController:imagePicker animated:YES];
    
    
    NSInteger src = UIImagePickerControllerSourceTypeCamera;
    
    if(!reader || (reader.sourceType != src))
        [self initReader: src];
    
    if([UIImagePickerController isSourceTypeAvailable: src]) {
        reader.sourceType = src;
        
        if(src == UIImagePickerControllerSourceTypeCamera) {
            reader.showsCameraControls = NO;
            [overlay setMode: OVERLAY_MODE_CANCEL];
            reader.cameraOverlayView = overlay;
            [overlay willAppear];
        }
        
        [self presentModalViewController:reader animated:NO];
    }
    else {
        NSString *title, *message;
        if(src == UIImagePickerControllerSourceTypeCamera) {
            title = @"Camera Unavailable";
            message = @"Unable to access the camera";
        }
        else {
            title = @"Image Library Unavailable";
            message = @"Unable to access the image library";
        }
        UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle: title
         message: message
         delegate: nil
         cancelButtonTitle: @"Cancel"
         otherButtonTitles: nil];
        [alert show];
    }
    
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    
}

@end
