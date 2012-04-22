//
//  GLBAppDelegate.m
//  WebGLBrowser
//
//  Created by Ben Vanik on 3/15/12.
//  Copyright (c) 2012 Ben Vanik. All rights reserved.
//

#import "GLBAppDelegate.h"

#import "GLBMasterViewController.h"

#import "GLBDetailViewController.h"

@interface GLBAppDelegate ()
- (void)addDefaultBookmarks;
@end

@implementation GLBAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;

- (void)dealloc
{
    [_window release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [_navigationController release];
    [_splitViewController release];
    [super dealloc];
}

// Unused - prevents warning
- (void)_enableRemoteInspector {
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // From Nathan de Vries:
    // http://atnan.com/blog/2011/11/17/enabling-remote-debugging-via-private-apis-in-mobile-safari/
    // This will enable remote debugging when running in the iOS simulator
    // Launch and navigate to http://localhost:9999
    // It does not yet work with devices
    [NSClassFromString(@"WebView") _enableRemoteInspector];

    [self addDefaultBookmarks];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        GLBMasterViewController *masterViewController = [[[GLBMasterViewController alloc] initWithNibName:@"GLBMasterViewController_iPhone" bundle:nil] autorelease];
        self.navigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
        self.window.rootViewController = self.navigationController;
        masterViewController.managedObjectContext = self.managedObjectContext;
    } else {
        GLBMasterViewController *masterViewController = [[[GLBMasterViewController alloc] initWithNibName:@"GLBMasterViewController_iPad" bundle:nil] autorelease];
        UINavigationController *masterNavigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
        
        GLBDetailViewController *detailViewController = [[[GLBDetailViewController alloc] initWithNibName:@"GLBDetailViewController_iPad" bundle:nil] autorelease];
        UINavigationController *detailNavigationController = [[[UINavigationController alloc] initWithRootViewController:detailViewController] autorelease];
    	
        self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
        self.splitViewController.delegate = detailViewController;
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
        
        self.window.rootViewController = self.splitViewController;
        masterViewController.detailViewController = detailViewController;
        masterViewController.managedObjectContext = self.managedObjectContext;
        detailViewController.managedObjectContext = self.managedObjectContext;
    }
        
    [application setStatusBarHidden:YES];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WebGLBrowser" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"WebGLBrowser.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Data

- (void)addDefaultBookmarks {
    [self addBookmark:@"http://www.google.com/"
            withTitle:@"Google"];
    [self addBookmark:@"http://webglsamples.googlecode.com/hg/aquarium/aquarium.html"
            withTitle:@"WebGL Aquarium"];
    [self addBookmark:@"http://learningwebgl.com/lessons/lesson05/index.html"
            withTitle:@"Learning WebGL Lesson 05"];
    [self addBookmark:@"http://learningwebgl.com/lessons/lesson16/index.html"
            withTitle:@"Learning WebGL Lesson 16"];
    [self addBookmark:@"http://media.tojicode.com/q3bsp/"
            withTitle:@"Quake 3 WebGL Demo"];
    [self addBookmark:@"https://cvs.khronos.org/svn/repos/registry/trunk/public/webgl/conformance-suites/1.0.0/webgl-conformance-tests.html"
            withTitle:@"WebGL Conformance Test 1.0.0"];
    [self addBookmark:@"https://cvs.khronos.org/svn/repos/registry/trunk/public/webgl/conformance-suites/1.0.1/webgl-conformance-tests.html"
            withTitle:@"WebGL Conformance Test 1.0.1"];
    [self addBookmark:@"https://cvs.khronos.org/svn/repos/registry/trunk/public/webgl/sdk/tests/webgl-conformance-tests.html"
            withTitle:@"WebGL Conformance Test (Latest)"];
    [self addBookmark:@"http://glsl.heroku.com/"
            withTitle:@"GLSL Sandbox"];
}

- (void)addBookmark:(NSString*)url
{
    [self addBookmark:url withTitle:url];
}

- (void)addBookmark:(NSString*)url withTitle:(NSString*)title
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Bookmark"
                                              inManagedObjectContext:context];
    
    // Don't allow duplicates - just update title
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:@"url like %@", url]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&error];
    
    NSManagedObject *obj = nil;
    if ([fetchedObjects count]) {
        obj = [fetchedObjects objectAtIndex:0];
    } else {    
        obj = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                            inManagedObjectContext:context];
    }
    
    [obj setValue:title forKey:@"title"];
    [obj setValue:url forKey:@"url"];
    [obj setValue:nil forKey:@"icon"];
    
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
