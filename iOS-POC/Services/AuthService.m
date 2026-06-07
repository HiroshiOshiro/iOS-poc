#import "AuthService.h"

static NSString * const kAuthErrorDomain = @"AuthServiceErrorDomain";

@implementation AuthService

+ (instancetype)shared {
    static AuthService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AuthService alloc] init];
    });
    return instance;
}

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
            completion:(AuthLoginCompletion)completion {
    // TODO: 本番サーバー実装後、実際の API リクエストに置き換える
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (email.length == 0 || password.length == 0) {
            NSError *error = [NSError errorWithDomain:kAuthErrorDomain
                                                 code:400
                                             userInfo:@{NSLocalizedDescriptionKey: @"メールアドレスとパスワードを入力してください"}];
            completion(nil, error);
            return;
        }

        if (password.length < 4) {
            NSError *error = [NSError errorWithDomain:kAuthErrorDomain
                                                 code:401
                                             userInfo:@{NSLocalizedDescriptionKey: @"メールアドレスまたはパスワードが正しくありません"}];
            completion(nil, error);
            return;
        }

        NSString *mockToken = [[NSUUID UUID] UUIDString];
        completion(mockToken, nil);
    });
}

@end
