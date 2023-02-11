//
// Created by Alexander Kormanovsky on 19.12.2022.
//

import Foundation

protocol CountdownTimerDelegate : AnyObject {

    func countdownTimerDidUpdateCount(_ countdownTimer: CountdownTimer,
                                      count: Int)
    func countdownTimerDidUpdateRepetitions(_ countdownTimer: CountdownTimer,
                                            pastRepetitions: Int,
                                            totalRepetitions: Int)

    func countdownTimerDidEndCounting(_ countdownTimer: CountdownTimer)

}

class CountdownTimer {

    private var timer: Timer?

    private var isDelayTimer = true
    private var isMainTimer = false

    private var interval = 0
    private var totalRepetitions = 0
    private var pastRepetitions = 0
    private var countdown = 0

    var isRunning = false
    /// Shows if the timer was paused at least once without reset
    var wasPaused = false

    weak var delegate: CountdownTimerDelegate?

    func set(intervalInMinutes: Int, totalRepetitions: Int, delay: Int) {
        self.interval = intervalInMinutes * 60
        self.totalRepetitions = totalRepetitions
        self.countdown = delay

        pastRepetitions = 0
    }

    /// Starts or resumes countdown
    func resume() {
        timer?.invalidate()
        timer = Timer(
                timeInterval: 1.0,
                target: self,
                selector: #selector(timerFired(_ :)),
                userInfo: nil,
                repeats: true)

        RunLoop.current.add(timer!, forMode: .default)

        isRunning = true
    }

    func pause() {
        wasPaused = true
        isRunning = false
        timer?.invalidate()
    }

    func reset() {
        wasPaused = false
        isRunning = false
        timer?.invalidate()
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
            if countdown == 0 {
                if pastRepetitions == totalRepetitions {
                    delegate?.countdownTimerDidEndCounting(self)
                    reset()
                    return
                }
                
                pastRepetitions += 1
                
                delegate?.countdownTimerDidUpdateRepetitions(self, pastRepetitions: pastRepetitions, totalRepetitions: totalRepetitions)

                countdown = interval
            }

            delegate?.countdownTimerDidUpdateCount(self, count: countdown)

            countdown -= 1
        }
    }

}
