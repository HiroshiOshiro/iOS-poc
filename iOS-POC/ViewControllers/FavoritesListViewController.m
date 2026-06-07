#import "FavoritesListViewController.h"
#import "FavoritesService.h"
#import "DogBreedDetailViewController.h"
#import "DogBreed.h"

static NSString * const kFavoriteCellIdentifier = @"FavoriteCell";

@interface FavoritesListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) NSArray<FavoriteBreed *> *favorites;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation FavoritesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"お気に入り";
    self.view.backgroundColor = UIColor.systemBackgroundColor;

    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;

    [self setupUI];
    [self reloadFavorites];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(favoritesDidChange:)
                                                 name:FavoritesDidChangeNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kFavoriteCellIdentifier];
    [self.view addSubview:self.tableView];

    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.emptyLabel.text = @"お気に入りはまだありません";
    self.emptyLabel.textColor = UIColor.secondaryLabelColor;
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.hidden = YES;
    [self.view addSubview:self.emptyLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.emptyLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.emptyLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];
}

- (void)reloadFavorites {
    self.favorites = [[FavoritesService shared] allFavoritesSortedByAddedDateDescending];
    self.emptyLabel.hidden = self.favorites.count > 0;
    self.tableView.hidden = self.favorites.count == 0;
    [self.tableView reloadData];
}

- (void)favoritesDidChange:(NSNotification *)note {
    [self reloadFavorites];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.favorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFavoriteCellIdentifier forIndexPath:indexPath];
    FavoriteBreed *fav = self.favorites[indexPath.row];

    UIListContentConfiguration *config = [cell defaultContentConfiguration];
    config.text = [fav.name capitalizedString];
    config.secondaryText = [NSString stringWithFormat:@"登録日時: %@", [self.dateFormatter stringFromDate:fav.addedAt]];
    config.image = [UIImage systemImageNamed:@"heart.fill"];
    config.imageProperties.tintColor = [UIColor systemRedColor];
    cell.contentConfiguration = config;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) { return; }
    FavoriteBreed *fav = self.favorites[indexPath.row];
    [[FavoritesService shared] removeFavoriteBreedName:fav.name];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FavoriteBreed *fav = self.favorites[indexPath.row];
    DogBreed *breed = [[DogBreed alloc] initWithName:fav.name subBreeds:@[]];
    DogBreedDetailViewController *detailVC = [[DogBreedDetailViewController alloc] initWithBreed:breed];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
