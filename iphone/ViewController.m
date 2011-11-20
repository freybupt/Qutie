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



@implementation ViewController

@synthesize listItems, reader, overlay, webView;

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
    webView.delegate = self;
    
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
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]isDirectory:NO]]];
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
    
    [self performSelector: @selector(dismissCamera)
               withObject: nil
               afterDelay: 2.0];
    
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Got it!" message:resultString delegate:self cancelButtonTitle:nil otherButtonTitles:@"Feed it!", nil];
//    [alert show];
    
	
	//Create a URL object from scaned link
//	NSURL *url = [NSURL URLWithString:resultString];
	
    //load the image if it's a image
//    NSString *headerUrl = [resultString substringToIndex:4];
//    if([headerUrl isEqualToString:@"http"]){
//        WebViewController *newWebView = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
//        newWebView.title = @"Qutie";
//        newWebView.urlAddress = resultString;
//        NSURLRequest *newRequestObj = [NSURLRequest requestWithURL:url];     
//        
//        //Load the request in the UIWebView.
//        [newWebView.webView loadRequest:newRequestObj];

//        [self presentModalViewController:newWebView animated:NO];
//    }
//    else{
//        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]isDirectory:NO]]];
        
//    }

    
    //add credit to it if it's not image and open website
    
    
    
	//URL Requst Object
//	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];     
	
	//Load the request in the UIWebView.
//	[webView loadRequest:requestObj];
    
    
    
    [self performSelector: @selector(playBeep)
                   withObject: nil
                afterDelay: 0.005];

    
}

- (void)dismissCamera{
    [self dismissModalViewControllerAnimated: NO];

}
- (void)webViewDidFinishLoad:(UIWebView *)wView {
    NSString *someHTML = [wView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('box')[0]"];   
    NSString *allHTML = [wView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    NSLog(@"someHTML: %@", someHTML);
    NSLog(@"allHTML: %@", allHTML);
    NSString *testString = @"http://www.google.com";
    [webView stringByEvaluatingJavaScriptFromString:testString];
    NSString* script = [NSString stringWithFormat:@"loadLink(%@);", testString];
    [webView stringByEvaluatingJavaScriptFromString:script];
}

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

- (void) playBeep {
    if(!beep)
        [self initAudio];
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
        
        [self presentModalViewController:reader animated:YES];
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
