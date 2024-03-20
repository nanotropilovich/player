import Foundation
import SwiftUI
import AVFoundation
import UniformTypeIdentifiers
import UIKit
import Combine

struct URLListView: View {
    @ObservedObject var store: URLStore
    @Binding var currentTime: TimeInterval
    @Binding var folder: Folder?
    @State private var isEditing = false
    @StateObject var fileImporter = FileImporter(
        allowedContentTypes: [UTType.audio],
        completion: { _ in
            
        }
    )
    init(store: URLStore, currentTime: Binding<TimeInterval>,folder: Binding<Folder?>) {
        self.store = store
        self._currentTime = currentTime
        self._folder = folder
    }
    
    var body: some View {
        VStack {
            Button(action: {
                store.removeAll()
            }) {
                Text("Clear URLs")
            }
            Button(action: {
                if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                    fileImporter.present(from: rootVC)
                }
            }) {
                Text("Import Audio File")
            }
            List {
                Section(header: Text("Folders")) {
                    ForEach(store.getAudioFiles(for: folder).indices, id: \.self) { index in
                        let audioFile = store.getAudioFiles(for: folder)[index]
                        
                        NavigationLink(destination:
                                        URLDetailView(urls: store.getAudioFiles(for: folder),
                                                      currentURLIndex: index,
                                                      store: store)
                        ) {
                            Text(audioFile.name)
                        }
                        
                        
                    }
                    .onDelete(perform: delete)
                }
                
            }
        }
        .sheet(isPresented: self.$fileImporter.isPresented) {
            DocumentPickerView(fileImporter: self.fileImporter)
                .edgesIgnoringSafeArea(.all)
        }
        
        .onAppear {
            if let data = UserDefaults.standard.value(forKey: "audioFiles") as? Data {
                if let urls = try? PropertyListDecoder().decode([AudioFile].self, from: data) {
                    store.urls = urls
                }
            }
        }
        .onChange(of: self.fileImporter.selectedFileURL) { selectedFileURL in
            if let url = selectedFileURL {
                store.add(url: url, folderID: folder?.id)
                
                store.saveUrls()
            }
        }
        .navigationTitle("Track List")
        .navigationBarItems(trailing: EditButton())
    }
    
    func deleteFolder(at offsets: IndexSet) {
        store.folders.remove(atOffsets: offsets)
    }
    
    func delete(at offsets: IndexSet) {
        store.urls.remove(atOffsets: offsets)
    }
}
