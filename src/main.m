#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <proscript.h>
#include <unistd.h>

@interface AppDelegate : UIResponder<UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window; 
@end

@implementation AppDelegate
- (BOOL) application: (UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*) launchOptions
{
   self.window = [[[UIWindow alloc] initWithFrame:  [[UIScreen mainScreen] bounds]] autorelease];
   self.window.backgroundColor = [UIColor whiteColor];
   UILabel *label = [[UILabel alloc] init];
   label.text = @"Hello, World 2!";
   label.center = CGPointMake( 100, 100 );
   [label sizeToFit];
   [self.window addSubview: label];
   [self.window makeKeyAndVisible];
   [label release];
   return YES;
}
@end

void query_complete(RC result)
{
   printf("Query has completed: %d\n", result);
}

int main(int argc, char *argv[])
{
     int fd = creat("/Users/trime/Desktop/my_log", S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
     close(STDERR_FILENO);
     dup(fd);
     close(fd);
     NSLog(@"Hello from IOS my_log");

    // Proscript expects to not be running in / !
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
    char path[PATH_MAX];
    if (!CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8 *)path, PATH_MAX))
    {
       NSLog(@"Error: Could not get directory");
       CFRelease(resourcesURL);
       return -1;
    }
    CFRelease(resourcesURL);
    chdir(path);

   // Now we can actually begin
   init_prolog();
   word w = MAKE_VCOMPOUND(MAKE_FUNCTOR(MAKE_ATOM("writeln"), 1), MAKE_ATOM("ohai"));
   execute_query(w, query_complete);
   @autoreleasepool
   {
      return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
   }
}
