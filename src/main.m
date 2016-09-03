#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

int main(int argc, char *argv[])
{
   @autoreleasepool
   {
      return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
   }
}
