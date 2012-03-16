//
//  GLBMasterViewController.h
//  WebGLBrowser
//
//  Created by Ben Vanik on 3/15/12.
//  Copyright (c) 2012 Ben Vanik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLBDetailViewController;

#import <CoreData/CoreData.h>

@interface GLBMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) GLBDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
