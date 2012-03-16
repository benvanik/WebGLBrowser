//
//  GLBDetailViewController.h
//  WebGLBrowser
//
//  Created by Ben Vanik on 3/15/12.
//  Copyright (c) 2012 Ben Vanik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLBDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UIBarButtonItem* fullScreenButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem* reloadButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem* backButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem* addButtonItem;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)fullScreenAction:(id)sender;
- (IBAction)reloadAction:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)addAction:(id)sender;

@end
