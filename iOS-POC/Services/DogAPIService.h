#import <Foundation/Foundation.h>
#import "DogBreed.h"

typedef void (^DogBreedsCompletion)(NSArray<DogBreed *> *breeds, NSError *error);
typedef void (^DogBreedImageCompletion)(NSString *imageURL, NSError *error);

@interface DogAPIService : NSObject

+ (instancetype)shared;

- (void)fetchBreedsWithCompletion:(DogBreedsCompletion)completion;
- (void)fetchRandomImageForBreed:(NSString *)breed completion:(DogBreedImageCompletion)completion;

@end
