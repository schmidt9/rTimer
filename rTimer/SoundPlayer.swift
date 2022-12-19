//
// Created by Alexander Kormanovsky on 20.12.2022.
//

import Foundation
import AVFoundation

struct SoundPlayer {

    private static var player: AVPlayer!

    static func play(_ sound: Sound) {
        player = AVPlayer(url: sound.url)
        player.play()
    }

}
