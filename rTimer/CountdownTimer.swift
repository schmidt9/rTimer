//
// Created by Alexander Kormanovsky on 19.12.2022.
//

import Foundation

protocol CountdownTimerDelegate : AnyObject {

    func countdownTimerDidUpdateCount(_ countdownTimer: CountdownTimer,
                                      count: Int)
    func countdownTimerDidUpdateRepetitions(_ countdownTimer: CountdownTimer,
                                            totalRepetitions: Int,
                                            leftRepetitions: Int)

}

class CountdownTimer {

    private var timer: Timer?

    private var isDelayTimer = true
    private var isMainTimer = false
    private var wasReset = true

    private var countdown = 0
    private var totalRepetitions = 0
    private var leftRepetitions = 0

    weak var delegate: CountdownTimerDelegate?

    func set(countdown: Int, totalRepetitions: Int) {
        self.countdown = countdown
        self.totalRepetitions = totalRepetitions
        leftRepetitions = totalRepetitions
    }

    func start() {
        timer?.invalidate()
        timer = Timer(
                timeInterval: 1.0,
                target: self,
                selector: #selector(timerFired(_ :)),
                userInfo: nil,
                repeats: true)
        RunLoop.current.add(timer!, forMode: .default)
    }

    func pause() {
        timer?.invalidate()
    }

    func reset() {
        wasReset = true
    }

    @objc private func timerFired(_ sender: Timer) {
        if isDelayTimer {
            if countdown == 0 {
                isDelayTimer = false
                isMainTimer = true
            } else {
                countdown -= 1
            }

            delegate?.countdownTimerDidUpdateCount(self, count: countdown)
        }

        if isMainTimer {
            guard totalRepetitions > 0 else { return }

            countdown -= 1

            delegate?.countdownTimerDidUpdateCount(self, count: countdown)
        }
    }

}