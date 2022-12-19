//
// Created by Alexander Kormanovsky on 19.12.2022.
//

import Foundation

struct SoundsManager {

    static var sounds: [Sound] {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil) else {
            return []
        }

        return urls.map { url in
            Sound(name: url.lastPathComponent, url: url)
        }
    }

    static func sound(named soundName: String) -> Sound? {
        sounds.first { $0.name == soundName }
    }

}
