import ComposableArchitecture
import SwiftUI

struct DogBreedsListView: View {
    let store: StoreOf<DogBreedsListFeature>
    let onSelectBreed: (DogBreedItem) -> Void

    var body: some View {
        ZStack {
            List {
                ForEach(store.breeds) { breed in
                    Button {
                        onSelectBreed(breed)
                    } label: {
                        row(for: breed)
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .refreshable {
                store.send(.refresh)
                while store.isLoading {
                    try? await Task.sleep(nanoseconds: 50_000_000)
                }
            }

            if store.isLoading && store.breeds.isEmpty {
                ProgressView()
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: Notification.Name("FavoritesDidChangeNotification")
            )
        ) { _ in
            store.send(.favoritesChanged)
        }
        .alert(
            "エラー",
            isPresented: Binding(
                get: { store.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        store.send(.errorDismissed)
                    }
                }
            ),
            presenting: store.errorMessage
        ) { _ in
            Button("OK") { store.send(.errorDismissed) }
        } message: { message in
            Text(message)
        }
    }

    @ViewBuilder
    private func row(for breed: DogBreedItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(breed.name.capitalized)
                    .font(.body)
                    .foregroundStyle(.primary)
                if !breed.subBreeds.isEmpty {
                    Text("\(breed.subBreeds.count) サブ犬種")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button {
                store.send(.favoriteToggled(breed.name))
            } label: {
                let isFavorite = store.favoriteNames.contains(breed.name)
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? Color.red : Color.gray)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderless)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
    }

}
