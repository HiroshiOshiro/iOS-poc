import ComposableArchitecture
import Foundation

struct DogBreedItem: Equatable, Identifiable, Sendable {
    let name: String
    let subBreeds: [String]
    var id: String { name }
}

struct DogBreedsClient: Sendable {
    var fetchBreeds: @Sendable () async throws -> [DogBreedItem]
}

extension DogBreedsClient: DependencyKey {
    static let liveValue = DogBreedsClient(
        fetchBreeds: {
            try await withCheckedThrowingContinuation { continuation in
                DogAPIService.shared().fetchBreeds { breeds, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    let items = (breeds ?? []).map { breed in
                        DogBreedItem(
                            name: breed.name,
                            subBreeds: breed.subBreeds ?? []
                        )
                    }
                    continuation.resume(returning: items)
                }
            }
        }
    )
}

struct FavoritesClient: Sendable {
    var allFavoriteNames: @Sendable () -> Set<String>
    var toggleFavorite: @Sendable (String) -> Void
}

extension FavoritesClient: DependencyKey {
    static let liveValue = FavoritesClient(
        allFavoriteNames: {
            let favs = FavoritesService.shared().allFavoritesSortedByAddedDateDescending()
            return Set(favs.map { $0.name })
        },
        toggleFavorite: { name in
            FavoritesService.shared().toggleFavoriteBreedName(name)
        }
    )
}

extension DependencyValues {
    var dogBreedsClient: DogBreedsClient {
        get { self[DogBreedsClient.self] }
        set { self[DogBreedsClient.self] = newValue }
    }

    var favoritesClient: FavoritesClient {
        get { self[FavoritesClient.self] }
        set { self[FavoritesClient.self] = newValue }
    }
}

@Reducer
struct DogBreedsListFeature {
    @ObservableState
    struct State: Equatable {
        var breeds: [DogBreedItem] = []
        var isLoading: Bool = false
        var errorMessage: String? = nil
        var favoriteNames: Set<String> = []
    }

    enum Action {
        case onAppear
        case refresh
        case loadResponse(Result<[DogBreedItem], NSError>)
        case favoriteToggled(String)
        case favoritesChanged
        case errorDismissed
    }

    @Dependency(\.dogBreedsClient) var dogBreedsClient
    @Dependency(\.favoritesClient) var favoritesClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.favoriteNames = favoritesClient.allFavoriteNames()
                if state.breeds.isEmpty && !state.isLoading {
                    return loadEffect(state: &state)
                }
                return .none

            case .refresh:
                return loadEffect(state: &state)

            case let .loadResponse(.success(items)):
                state.isLoading = false
                state.breeds = items
                return .none

            case let .loadResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            case let .favoriteToggled(name):
                favoritesClient.toggleFavorite(name)
                state.favoriteNames = favoritesClient.allFavoriteNames()
                return .none

            case .favoritesChanged:
                state.favoriteNames = favoritesClient.allFavoriteNames()
                return .none

            case .errorDismissed:
                state.errorMessage = nil
                return .none
            }
        }
    }

    private func loadEffect(state: inout State) -> Effect<Action> {
        state.isLoading = true
        state.errorMessage = nil
        return .run { [client = dogBreedsClient] send in
            do {
                let items = try await client.fetchBreeds()
                await send(.loadResponse(.success(items)))
            } catch {
                await send(.loadResponse(.failure(error as NSError)))
            }
        }
    }
}
