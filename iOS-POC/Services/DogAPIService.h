#import <Foundation/Foundation.h>
#import "DogBreed.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DogBreedsCompletion)(NSArray<DogBreed *> * _Nullable breeds, NSError * _Nullable error);
typedef void (^DogBreedImageCompletion)(NSString * _Nullable imageURL, NSError * _Nullable error);

@interface DogAPIService : NSObject

+ (instancetype)shared;

- (void)fetchBreedsWithCompletion:(DogBreedsCompletion)completion;
- (void)fetchRandomImageForBreed:(NSString *)breed completion:(DogBreedImageCompletion)completion;

@end

NS_ASSUME_NONNULL_END
