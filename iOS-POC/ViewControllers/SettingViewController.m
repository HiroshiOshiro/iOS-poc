#import "SettingViewController.h"
#import "AuthService.h"

@interface SettingViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Setting";

    [self setupUI];
}

- (void)setupUI {
    self.emailField = [[UITextField alloc] init];
    self.emailField.placeholder = @"Email";
    self.emailField.borderStyle = UITextBorderStyleRoundedRect;
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailField.returnKeyType = UIReturnKeyNext;
    self.emailField.delegate = self;
    self.emailField.translatesAutoresizingMaskIntoConstraints = NO;

    self.passwordField = [[UITextField alloc] init];
    self.passwordField.placeholder = @"Password";
    self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordField.secureTextEntry = YES;
    self.passwordField.returnKeyType = UIReturnKeyGo;
    self.passwordField.delegate = self;
    self.passwordField.translatesAutoresizingMaskIntoConstraints = NO;

    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.loginButton.backgroundColor = [UIColor systemBlueColor];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginButton.layer.cornerRadius = 8;
    [self.loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    self.statusLabel.textColor = [UIColor secondaryLabelColor];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:self.emailField];
    [self.view addSubview:self.passwordField];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.spinner];
    [self.view addSubview:self.statusLabel];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.emailField.topAnchor constraintEqualToAnchor:safe.topAnchor constant:32],
        [self.emailField.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [self.emailField.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],
        [self.emailField.heightAnchor constraintEqualToConstant:44],

        [self.passwordField.topAnchor constraintEqualToAnchor:self.emailField.bottomAnchor constant:12],
        [self.passwordField.leadingAnchor constraintEqualToAnchor:self.emailField.leadingAnchor],
        [self.passwordField.trailingAnchor constraintEqualToAnchor:self.emailField.trailingAnchor],
        [self.passwordField.heightAnchor constraintEqualToConstant:44],

        [self.loginButton.topAnchor constraintEqualToAnchor:self.passwordField.bottomAnchor constant:24],
        [self.loginButton.leadingAnchor constraintEqualToAnchor:self.emailField.leadingAnchor],
        [self.loginButton.trailingAnchor constraintEqualToAnchor:self.emailField.trailingAnchor],
        [self.loginButton.heightAnchor constraintEqualToConstant:48],

        [self.spinner.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.spinner.topAnchor constraintEqualToAnchor:self.loginButton.bottomAnchor constant:16],

        [self.statusLabel.topAnchor constraintEqualToAnchor:self.spinner.bottomAnchor constant:12],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.emailField.leadingAnchor],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.emailField.trailingAnchor],
    ]];
}

- (void)loginTapped {
    [self.view endEditing:YES];
    [self setLoading:YES];
    self.statusLabel.text = nil;

    NSString *email = self.emailField.text ?: @"";
    NSString *password = self.passwordField.text ?: @"";

    __weak typeof(self) weakSelf = self;
    [[AuthService shared] loginWithEmail:email password:password completion:^(NSString *token, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        [strongSelf setLoading:NO];

        if (error) {
            strongSelf.statusLabel.textColor = [UIColor systemRedColor];
            strongSelf.statusLabel.text = error.localizedDescription;
            return;
        }

        strongSelf.statusLabel.textColor = [UIColor systemGreenColor];
        strongSelf.statusLabel.text = [NSString stringWithFormat:@"ログイン成功 (mock token: %@)", token];
    }];
}

- (void)setLoading:(BOOL)loading {
    self.loginButton.enabled = !loading;
    self.emailField.enabled = !loading;
    self.passwordField.enabled = !loading;
    self.loginButton.alpha = loading ? 0.5 : 1.0;
    if (loading) {
        [self.spinner startAnimating];
    } else {
        [self.spinner stopAnimating];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self loginTapped];
    }
    return YES;
}

@end
