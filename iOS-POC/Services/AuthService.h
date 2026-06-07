#import <Foundation/Foundation.h>

typedef void (^AuthLoginCompletion)(NSString *token, NSError *error);

@interface AuthService : NSObject

+ (instancetype)shared;

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(AuthLoginCompletion)completion;

@end
