#import <Foundation/Foundation.h>

@interface DogBreed : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray<NSString *> *subBreeds;

- (instancetype)initWithName:(NSString *)name subBreeds:(NSArray<NSString *> *)subBreeds;

@end
