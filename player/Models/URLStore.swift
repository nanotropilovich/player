

import Foundation
class URLStore: ObservableObject {
    @Published var urls: [AudioFile] {
        didSet {
            saveUrls()
        }
    }
    @Published var folders: [Folder] {
        didSet {
            saveFolders()
        }
    }
    func updateCurrentTime(for url: AudioFile, to time: TimeInterval) {
        if let index = urls.firstIndex(where: { $0.url == url.url }) {
            urls[index].currentTime = time
            saveUrls()
        }
    }
    init() {
        if let data = UserDefaults.standard.data(forKey: "audioFiles"),
           let audioFiles = try? JSONDecoder().decode([AudioFile].self, from: data) {
            self.urls = audioFiles
        } else {
            self.urls = []
        }
        
        if let data = UserDefaults.standard.data(forKey: "folders"),
           let folders = try? JSONDecoder().decode([Folder].self, from: data) {
            self.folders = folders
        } else {
            self.folders = []
        }
    }

    func getAudioFiles(for folder: Folder?) -> [AudioFile] {
        for url in urls {
            print(url.folderID,folder?.id)
        }
        return urls.filter { $0.folderID == folder?.id }
    }
    func updateName(for index: Int, newName: String) {
           urls[index].name = newName
           saveUrls()
       }
    func add(url: URL, folderID: UUID? = nil) {
        let audioFile = AudioFile(url: url, folderID: folderID)
        urls.append(audioFile)
        saveUrls()
    }

    func removeAll() {
        urls.removeAll()
        saveUrls()
    }

    func remove(atOffsets offsets: IndexSet) {
        urls.remove(atOffsets: offsets)
        saveUrls()
    }

    func removeFolder(atOffsets offsets: IndexSet) {
        folders.remove(atOffsets: offsets)
        saveFolders()
    }

    public func saveUrls() {
        let data = try? JSONEncoder().encode(urls)
        UserDefaults.standard.set(data, forKey: "audioFiles")
    }

    private func saveFolders() {
        let data = try? JSONEncoder().encode(folders)
        UserDefaults.standard.set(data, forKey: "folders")
    }
}
