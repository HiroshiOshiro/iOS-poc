#import <Foundation/Foundation.h>

extern NSNotificationName const FavoritesDidChangeNotification;

@interface FavoriteBreed : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSDate *addedAt;

- (instancetype)initWithName:(NSString *)name addedAt:(NSDate *)addedAt;

@end

@interface FavoritesService : NSObject

+ (instancetype)shared;

- (BOOL)isFavoriteBreedName:(NSString *)name;
- (NSDate *)addedAtForBreedName:(NSString *)name;
- (void)addFavoriteBreedName:(NSString *)name;
- (void)removeFavoriteBreedName:(NSString *)name;
- (void)toggleFavoriteBreedName:(NSString *)name;
- (NSArray<FavoriteBreed *> *)allFavoritesSortedByAddedDateDescending;

@end
