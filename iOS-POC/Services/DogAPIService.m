#import "DogAPIService.h"

static NSString * const kBreedsListURL = @"https://dog.ceo/api/breeds/list/all";
static NSString * const kBreedImageURLFormat = @"https://dog.ceo/api/breed/%@/images/random";

@implementation DogAPIService

+ (instancetype)shared {
    static DogAPIService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DogAPIService alloc] init];
    });
    return instance;
}

- (void)fetchBreedsWithCompletion:(DogBreedsCompletion)completion {
    NSURL *url = [NSURL URLWithString:kBreedsListURL];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, error); });
                return;
            }

            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, jsonError); });
                return;
            }

            NSDictionary *message = json[@"message"];
            NSMutableArray<DogBreed *> *breeds = [NSMutableArray array];
            NSArray *sortedKeys = [message.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            for (NSString *breedName in sortedKeys) {
                NSArray *subBreeds = message[breedName];
                DogBreed *breed = [[DogBreed alloc] initWithName:breedName subBreeds:subBreeds];
                [breeds addObject:breed];
            }

            dispatch_async(dispatch_get_main_queue(), ^{ completion([breeds copy], nil); });
        }];
    [task resume];
}

- (void)fetchRandomImageForBreed:(NSString *)breed completion:(DogBreedImageCompletion)completion {
    NSString *urlString = [NSString stringWithFormat:kBreedImageURLFormat, breed];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, error); });
                return;
            }

            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{ completion(nil, jsonError); });
                return;
            }

            NSString *imageURL = json[@"message"];
            dispatch_async(dispatch_get_main_queue(), ^{ completion(imageURL, nil); });
        }];
    [task resume];
}

@end
