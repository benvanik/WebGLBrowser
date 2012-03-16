//
//  GLBDetailViewController.m
//  WebGLBrowser
//
//  Created by Ben Vanik on 3/15/12.
//  Copyright (c) 2012 Ben Vanik. All rights reserved.
//

#import "GLBDetailViewController.h"

#import "GLBAppDelegate.h"

@interface UIBackingWebView
- (void)_setWebGLEnabled:(BOOL)value;
@end

@interface GLBDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation GLBDetailViewController

@synthesize masterPopoverController = _masterPopoverController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize detailItem = _detailItem;
@synthesize fullScreenButtonItem = _fullScreenButtonItem;
@synthesize reloadButtonItem = _reloadButtonItem;
@synthesize backButtonItem = _backButtonItem;
@synthesize addButtonItem = _addButtonItem;
@synthesize webView = _webView;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_masterPopoverController release];
    [__managedObjectContext release];
    [_detailItem release];
    [_fullScreenButtonItem release];
    [_reloadButtonItem release];
    [_backButtonItem release];
    [_addButtonItem release];
    [_webView release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release]; 
        _detailItem = [newDetailItem retain]; 

        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)navigateToURL:(NSString*)target
{
    NSURL* url = [NSURL URLWithString:target];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [[self webView] loadRequest:request];
}

- (void)configureView
{
    // HACK: clear back/forward history
    id internalWebView = [[[self webView] _documentView] webView];       
    [internalWebView setMaintainsBackForwardList:NO];
    [internalWebView setMaintainsBackForwardList:YES];

    if ([self detailItem]) {
        [self setTitle:@""];
        [self navigateToURL:[self.detailItem valueForKey:@"url"]];
    } else {
        [self setTitle:NSLocalizedString(@"Page", @"Page")];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Behavior

- (IBAction)fullScreenAction:(id)sender {
    GLBAppDelegate *app = (GLBAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    [[app splitViewController] setWantsFullScreenLayout:NO];
}

- (IBAction)reloadAction:(id)sender {
    [self.webView reload];
}

- (IBAction)backAction:(id)sender {
    [self.webView goBack];
}

- (IBAction)addAction:(id)sender {
    NSString* title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString* url = [self.webView stringByEvaluatingJavaScriptFromString:@"window.location.toString()"];
    
    GLBAppDelegate *app = (GLBAppDelegate*)[[UIApplication sharedApplication] delegate];
    [app addBookmark:url withTitle:title];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    self.navigationItem.rightBarButtonItems =
        [NSArray arrayWithObjects:self.fullScreenButtonItem,
                                  self.addButtonItem,
                                  self.reloadButtonItem,
                                  self.backButtonItem, nil];
    
    // Enable WebGL
    id webDocumentView = [self.webView performSelector:@selector(_browserView)];
    id backingWebView = [webDocumentView performSelector:@selector(webView)];
    [(UIBackingWebView*)backingWebView _setWebGLEnabled:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resumed:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)resumed:(id)sender {
    [[self navigationController] setNavigationBarHidden:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self navigateToURL:@"about:blank"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self navigateToURL:@"about:blank"];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Page", @"Page");
    }
    return self;
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Bookmarks", @"Bookmarks");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
