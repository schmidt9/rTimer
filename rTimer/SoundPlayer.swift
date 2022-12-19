//
// Created by Alexander Kormanovsky on 20.12.2022.
//

import Foundation
import AVFoundation

class SoundPlayer {

    private static var player: AVPlayer!
    private static var sound: Sound?
    private static var playsTwice = false

    static func play(_ sound: Sound?, twice: Bool = false) {
        self.sound = sound
        playsTwice = twice

        guard let sound = sound else { return }

        player = AVPlayer(url: sound.url)

        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(playerDidFinishPlaying(notification:)),
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: player.currentItem)

        player.play()
    }

    @objc static func playerDidFinishPlaying(notification: NSNotification) {
        if playsTwice {
            play(sound)
        }
    }

}
