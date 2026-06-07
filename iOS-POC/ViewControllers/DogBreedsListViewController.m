#import "DogBreedsListViewController.h"
#import "DogBreedDetailViewController.h"
#import "DogAPIService.h"
#import "DogBreed.h"
#import "FavoritesService.h"

static NSString * const kCellIdentifier = @"BreedCell";

@interface DogBreedsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSArray<DogBreed *> *breeds;

@end

@implementation DogBreedsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"犬種一覧";
    [self setupUI];
    [self loadBreeds];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favoritesDidChange:)
                                                 name:FavoritesDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    [self.view addSubview:self.tableView];

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.activityIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];
}

- (void)loadBreeds {
    [self.activityIndicator startAnimating];
    self.tableView.hidden = YES;

    [[DogAPIService shared] fetchBreedsWithCompletion:^(NSArray<DogBreed *> *breeds, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.tableView.hidden = NO;

        if (error) {
            [self showError:error];
            return;
        }
        self.breeds = breeds;
        [self.tableView reloadData];
    }];
}

- (void)showError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"エラー"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)favoritesDidChange:(NSNotification *)note {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.breeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    DogBreed *breed = self.breeds[indexPath.row];

    UIListContentConfiguration *config = [cell defaultContentConfiguration];
    config.text = [breed.name capitalizedString];
    if (breed.subBreeds.count > 0) {
        config.secondaryText = [NSString stringWithFormat:@"%ld サブ犬種", (long)breed.subBreeds.count];
    } else {
        config.secondaryText = nil;
    }
    cell.contentConfiguration = config;

    UIButton *favButton = [UIButton buttonWithType:UIButtonTypeSystem];
    BOOL isFavorite = [[FavoritesService shared] isFavoriteBreedName:breed.name];
    NSString *symbolName = isFavorite ? @"heart.fill" : @"heart";
    [favButton setImage:[UIImage systemImageNamed:symbolName] forState:UIControlStateNormal];
    favButton.tintColor = isFavorite ? [UIColor systemRedColor] : [UIColor systemGrayColor];
    favButton.frame = CGRectMake(0, 0, 44, 44);
    favButton.tag = indexPath.row;
    [favButton addTarget:self action:@selector(favoriteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = favButton;

    return cell;
}

- (void)favoriteButtonTapped:(UIButton *)sender {
    NSInteger row = sender.tag;
    if (row < 0 || row >= (NSInteger)self.breeds.count) { return; }
    DogBreed *breed = self.breeds[row];
    [[FavoritesService shared] toggleFavoriteBreedName:breed.name];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DogBreed *breed = self.breeds[indexPath.row];
    DogBreedDetailViewController *detailVC = [[DogBreedDetailViewController alloc] initWithBreed:breed];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
