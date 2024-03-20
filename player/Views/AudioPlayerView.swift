import SwiftUI
struct AudioPlayerView: View {
    @ObservedObject var store: URLStore
    @ObservedObject var audioPlayerViewModel: AudioPlayerViewModel 
    @Environment(\.presentationMode) var presentationMode
    @State private var isAddingFolder = false
    
    var body: some View {
        VStack {
            Text("Tracks")
            
            NavigationView {
                List {
                    ForEach(store.folders.indices, id: \.self) { index in
                        NavigationLink(destination: URLListView(store: store, currentTime: Binding(get: { self.audioPlayerViewModel.currentTime ?? 0 }, set: { newValue in self.audioPlayerViewModel.seek(to: newValue) }), folder: Binding.constant(store.folders[index]))) {
                            Text(store.folders[index].name)
                        }
                    }
                    .onDelete(perform: { offsets in
                        store.removeFolder(atOffsets: offsets)
                    })
                }
                .listStyle(PlainListStyle())
                .navigationBarItems(trailing: EditButton())
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isAddingFolder.toggle()
                        }) {
                            Text("Create Folder")
                        }
                        .sheet(isPresented: $isAddingFolder) {
                            AddFolderView(store: store, isPresented: $isAddingFolder)
                        }
                    }
                }
            }
        }
    }
}
