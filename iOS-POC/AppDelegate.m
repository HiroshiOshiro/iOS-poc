#import "AppDelegate.h"
#import "FavoritesListViewController.h"
#import "SettingViewController.h"
#import "iOS_POC-Swift.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];

    UIViewController *listVC = [DogBreedsListSceneFactory makeViewController];
    UINavigationController *dogNavVC = [[UINavigationController alloc] initWithRootViewController:listVC];
    dogNavVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Dog"
                                                        image:[UIImage systemImageNamed:@"pawprint"]
                                                          tag:0];

    FavoritesListViewController *favoritesVC = [[FavoritesListViewController alloc] init];
    UINavigationController *favoritesNavVC = [[UINavigationController alloc] initWithRootViewController:favoritesVC];
    favoritesNavVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Favorites"
                                                              image:[UIImage systemImageNamed:@"heart"]
                                                                tag:1];

    SettingViewController *settingVC = [[SettingViewController alloc] init];
    UINavigationController *settingNavVC = [[UINavigationController alloc] initWithRootViewController:settingVC];
    settingNavVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Setting"
                                                            image:[UIImage systemImageNamed:@"gearshape"]
                                                              tag:2];

    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[dogNavVC, favoritesNavVC, settingNavVC];

    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
