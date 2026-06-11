#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DogBreed : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray<NSString *> *subBreeds;

- (instancetype)initWithName:(NSString *)name subBreeds:(NSArray<NSString *> *)subBreeds;

@end

NS_ASSUME_NONNULL_END
