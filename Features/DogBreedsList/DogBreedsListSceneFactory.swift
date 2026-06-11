import ComposableArchitecture
import SwiftUI
import UIKit

@objc public final class DogBreedsListSceneFactory: NSObject {
    @objc public static func makeViewController() -> UIViewController {
        let store = Store(initialState: DogBreedsListFeature.State()) {
            DogBreedsListFeature()
        }
        return DogBreedsListHostingController(store: store)
    }
}

final class NavigationCoordinator {
    var onSelect: ((DogBreedItem) -> Void)?
}

private final class DogBreedsListHostingController: UIHostingController<DogBreedsListView> {
    private let coordinator: NavigationCoordinator

    init(store: StoreOf<DogBreedsListFeature>) {
        let coordinator = NavigationCoordinator()
        self.coordinator = coordinator
        let rootView = DogBreedsListView(store: store) { [coordinator] item in
            coordinator.onSelect?(item)
        }
        super.init(rootView: rootView)
        coordinator.onSelect = { [weak self] item in
            guard let self = self else { return }
            let breed = DogBreed(name: item.name, subBreeds: item.subBreeds)
            let detailVC = DogBreedDetailViewController(breed: breed)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        title = "犬種一覧"
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
