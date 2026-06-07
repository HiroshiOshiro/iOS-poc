#import "DogBreed.h"

@implementation DogBreed

- (instancetype)initWithName:(NSString *)name subBreeds:(NSArray<NSString *> *)subBreeds {
    self = [super init];
    if (self) {
        _name = name;
        _subBreeds = subBreeds ?: @[];
    }
    return self;
}

@end
