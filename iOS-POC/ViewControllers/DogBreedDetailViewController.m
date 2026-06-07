#import "DogBreedDetailViewController.h"
#import "DogAPIService.h"
#import "FavoritesService.h"

@interface DogBreedDetailViewController ()

@property (nonatomic, strong) DogBreed *breed;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *dogImageView;
@property (nonatomic, strong) UIActivityIndicatorView *imageIndicator;
@property (nonatomic, strong) UILabel *breedNameLabel;
@property (nonatomic, strong) UILabel *subBreedsLabel;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UILabel *favoriteStatusLabel;

@end

@implementation DogBreedDetailViewController

- (instancetype)initWithBreed:(DogBreed *)breed {
    self = [super init];
    if (self) {
        _breed = breed;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [self.breed.name capitalizedString];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    [self setupUI];
    [self updateFavoriteUI];
    [self loadRandomImage];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favoritesDidChange:)
                                                 name:FavoritesDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];

    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:contentView];

    // Dog image
    self.dogImageView = [[UIImageView alloc] init];
    self.dogImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.dogImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.dogImageView.clipsToBounds = YES;
    self.dogImageView.backgroundColor = UIColor.secondarySystemBackgroundColor;
    self.dogImageView.layer.cornerRadius = 12;
    [contentView addSubview:self.dogImageView];

    // Activity indicator over image
    self.imageIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.imageIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageIndicator.hidesWhenStopped = YES;
    [contentView addSubview:self.imageIndicator];

    // Breed name label
    self.breedNameLabel = [[UILabel alloc] init];
    self.breedNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.breedNameLabel.font = [UIFont boldSystemFontOfSize:24];
    self.breedNameLabel.text = [self.breed.name capitalizedString];
    self.breedNameLabel.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:self.breedNameLabel];

    // Sub-breeds label
    self.subBreedsLabel = [[UILabel alloc] init];
    self.subBreedsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subBreedsLabel.font = [UIFont systemFontOfSize:16];
    self.subBreedsLabel.textColor = UIColor.secondaryLabelColor;
    self.subBreedsLabel.numberOfLines = 0;
    self.subBreedsLabel.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:self.subBreedsLabel];

    if (self.breed.subBreeds.count > 0) {
        NSArray *capitalized = [self.breed.subBreeds valueForKey:@"capitalizedString"];
        self.subBreedsLabel.text = [NSString stringWithFormat:@"サブ犬種: %@", [capitalized componentsJoinedByString:@", "]];
    } else {
        self.subBreedsLabel.text = @"サブ犬種なし";
    }

    // Favorite status label
    self.favoriteStatusLabel = [[UILabel alloc] init];
    self.favoriteStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.favoriteStatusLabel.font = [UIFont systemFontOfSize:14];
    self.favoriteStatusLabel.textColor = UIColor.secondaryLabelColor;
    self.favoriteStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.favoriteStatusLabel.numberOfLines = 0;
    [contentView addSubview:self.favoriteStatusLabel];

    // Refresh button
    self.refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.refreshButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.refreshButton setTitle:@"別の画像を表示" forState:UIControlStateNormal];
    self.refreshButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.refreshButton addTarget:self action:@selector(loadRandomImage) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:self.refreshButton];

    // Layout
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        [contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],

        [self.dogImageView.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:20],
        [self.dogImageView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [self.dogImageView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [self.dogImageView.heightAnchor constraintEqualToConstant:280],

        [self.imageIndicator.centerXAnchor constraintEqualToAnchor:self.dogImageView.centerXAnchor],
        [self.imageIndicator.centerYAnchor constraintEqualToAnchor:self.dogImageView.centerYAnchor],

        [self.breedNameLabel.topAnchor constraintEqualToAnchor:self.dogImageView.bottomAnchor constant:20],
        [self.breedNameLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [self.breedNameLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],

        [self.subBreedsLabel.topAnchor constraintEqualToAnchor:self.breedNameLabel.bottomAnchor constant:12],
        [self.subBreedsLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [self.subBreedsLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],

        [self.favoriteStatusLabel.topAnchor constraintEqualToAnchor:self.subBreedsLabel.bottomAnchor constant:16],
        [self.favoriteStatusLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [self.favoriteStatusLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],

        [self.refreshButton.topAnchor constraintEqualToAnchor:self.favoriteStatusLabel.bottomAnchor constant:20],
        [self.refreshButton.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor],
        [self.refreshButton.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-30],
    ]];
}

- (void)updateFavoriteUI {
    BOOL isFavorite = [[FavoritesService shared] isFavoriteBreedName:self.breed.name];
    NSString *symbolName = isFavorite ? @"heart.fill" : @"heart";
    UIBarButtonItem *favItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:symbolName]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(favoriteButtonTapped)];
    favItem.tintColor = isFavorite ? [UIColor systemRedColor] : nil;
    self.navigationItem.rightBarButtonItem = favItem;

    if (isFavorite) {
        NSDate *addedAt = [[FavoritesService shared] addedAtForBreedName:self.breed.name];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
        self.favoriteStatusLabel.text = [NSString stringWithFormat:@"お気に入り登録日時: %@", [formatter stringFromDate:addedAt]];
        self.favoriteStatusLabel.textColor = [UIColor systemRedColor];
    } else {
        self.favoriteStatusLabel.text = @"未登録";
        self.favoriteStatusLabel.textColor = UIColor.secondaryLabelColor;
    }
}

- (void)favoriteButtonTapped {
    [[FavoritesService shared] toggleFavoriteBreedName:self.breed.name];
}

- (void)favoritesDidChange:(NSNotification *)note {
    [self updateFavoriteUI];
}

- (void)loadRandomImage {
    [self.imageIndicator startAnimating];
    self.dogImageView.image = nil;
    self.refreshButton.enabled = NO;

    [[DogAPIService shared] fetchRandomImageForBreed:self.breed.name completion:^(NSString *imageURL, NSError *error) {
        self.refreshButton.enabled = YES;
        if (error || !imageURL) {
            [self.imageIndicator stopAnimating];
            return;
        }
        NSURL *url = [NSURL URLWithString:imageURL];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *downloadError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.imageIndicator stopAnimating];
                    if (data && !downloadError) {
                        self.dogImageView.image = [UIImage imageWithData:data];
                    }
                });
            }];
        [task resume];
    }];
}

@end
