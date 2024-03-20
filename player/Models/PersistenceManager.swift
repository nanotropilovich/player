import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()

    func saveTracks(_ tracks: [AudioFile], forFolderID folderID: UUID) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("\(folderID)").appendingPathExtension("plist")

        let propertyListEncoder = PropertyListEncoder()
        let encodedTracks = try? propertyListEncoder.encode(tracks)
        try? encodedTracks?.write(to: archiveURL, options: .noFileProtection)
    }

    func loadTracks(forFolderID folderID: UUID) -> [AudioFile] {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("\(folderID)").appendingPathExtension("plist")

        let propertyListDecoder = PropertyListDecoder()
        if let retrievedTracksData = try? Data(contentsOf: archiveURL),
           let decodedTracks = try? propertyListDecoder.decode([AudioFile].self, from: retrievedTracksData) {
            return decodedTracks
        }
        return []
    }
}
