#import "FavoritesService.h"

NSNotificationName const FavoritesDidChangeNotification = @"FavoritesDidChangeNotification";

static NSString * const kFavoritesUserDefaultsKey = @"FavoritesService.favorites";

@implementation FavoriteBreed

- (instancetype)initWithName:(NSString *)name addedAt:(NSDate *)addedAt {
    self = [super init];
    if (self) {
        _name = [name copy];
        _addedAt = [addedAt copy];
    }
    return self;
}

@end

@interface FavoritesService ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDate *> *favorites;

@end

@implementation FavoritesService

+ (instancetype)shared {
    static FavoritesService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FavoritesService alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadFromUserDefaults];
    }
    return self;
}

- (void)loadFromUserDefaults {
    NSDictionary *stored = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kFavoritesUserDefaultsKey];
    NSMutableDictionary<NSString *, NSDate *> *dict = [NSMutableDictionary dictionary];
    [stored enumerateKeysAndObjectsUsingBlock:^(NSString *name, id value, BOOL *stop) {
        if ([value isKindOfClass:[NSDate class]]) {
            dict[name] = value;
        } else if ([value isKindOfClass:[NSNumber class]]) {
            dict[name] = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
        }
    }];
    self.favorites = dict;
}

- (void)persist {
    NSMutableDictionary *toStore = [NSMutableDictionary dictionary];
    [self.favorites enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSDate *date, BOOL *stop) {
        toStore[name] = date;
    }];
    [[NSUserDefaults standardUserDefaults] setObject:toStore forKey:kFavoritesUserDefaultsKey];
}

- (BOOL)isFavoriteBreedName:(NSString *)name {
    if (name.length == 0) { return NO; }
    return self.favorites[name] != nil;
}

- (NSDate *)addedAtForBreedName:(NSString *)name {
    if (name.length == 0) { return nil; }
    return self.favorites[name];
}

- (void)addFavoriteBreedName:(NSString *)name {
    if (name.length == 0) { return; }
    if (self.favorites[name]) { return; }
    self.favorites[name] = [NSDate date];
    [self persist];
    [self postChangeNotification];
}

- (void)removeFavoriteBreedName:(NSString *)name {
    if (name.length == 0) { return; }
    if (!self.favorites[name]) { return; }
    [self.favorites removeObjectForKey:name];
    [self persist];
    [self postChangeNotification];
}

- (void)toggleFavoriteBreedName:(NSString *)name {
    if ([self isFavoriteBreedName:name]) {
        [self removeFavoriteBreedName:name];
    } else {
        [self addFavoriteBreedName:name];
    }
}

- (NSArray<FavoriteBreed *> *)allFavoritesSortedByAddedDateDescending {
    NSMutableArray<FavoriteBreed *> *items = [NSMutableArray array];
    [self.favorites enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSDate *date, BOOL *stop) {
        [items addObject:[[FavoriteBreed alloc] initWithName:name addedAt:date]];
    }];
    [items sortUsingComparator:^NSComparisonResult(FavoriteBreed *a, FavoriteBreed *b) {
        return [b.addedAt compare:a.addedAt];
    }];
    return [items copy];
}

- (void)postChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:FavoritesDidChangeNotification object:self];
}

@end
