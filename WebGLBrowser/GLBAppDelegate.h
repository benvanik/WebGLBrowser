//
//  GLBAppDelegate.h
//  WebGLBrowser
//
//  Created by Ben Vanik on 3/15/12.
//  Copyright (c) 2012 Ben Vanik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UISplitViewController *splitViewController;

- (void)addBookmark:(NSString*)url;
- (void)addBookmark:(NSString*)url withTitle:(NSString*)title;

@end
