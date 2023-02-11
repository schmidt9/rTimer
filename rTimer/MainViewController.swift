//
//  MainViewController.swift
//  rTimer
//
//  Created by Alexander Kormanovsky on 18.12.2022.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    @IBOutlet var timerContainerView: UIView!
    
    @IBOutlet var intervalTextField: UITextField!
    
    @IBOutlet var repetitionsCountTextField: UITextField!
    
    @IBOutlet var delayTextField: UITextField!
    
    @IBOutlet var runButton: UIButton!
    
    @IBOutlet var resetButton: UIButton!
    
    @IBOutlet var pickSoundButton: UIButton!
    
    @IBOutlet var soundNameLabel: UILabel!
    
    @IBOutlet var playSoundSwitch: UISwitch!
    
    @IBOutlet var vibrateSwitch: UISwitch!
    
    private var activeTextField: UITextField?
    
    private var countdownTimer = CountdownTimer()
    
    private var selectedSound: Sound?
    
    private var vibrationCompletionCallback: (() -> Void)?
    
    private static var delayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "mm:ss"
        
        return formatter
    }()
    
    // MARK: --
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? SoundsTableViewController {
            viewController.delegate = self
            viewController.soundName = soundNameLabel.text ?? ""
        }
    }
    
    // MARK: UI
    
    func setup() {
        
        timerContainerView.layer.cornerRadius = 8
        
        for textField in [intervalTextField, repetitionsCountTextField, delayTextField] {
            let toolbar = UIToolbar()
            
            let spacingItem = UIBarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil)
            
            let nextItem = UIBarButtonItem(
                title: "Далее",
                style: .plain,
                target: self,
                action: #selector(textFieldDone(_:)))
            
            let doneItem = UIBarButtonItem(
                title: "Готово",
                style: .done,
                target: self,
                action: #selector(textFieldDone(_:)))
            
            toolbar.items = [spacingItem, nextItem, doneItem]
            toolbar.sizeToFit()
            textField?.inputAccessoryView = toolbar
        }
        
        for button in [runButton, resetButton] {
            button!.layer.cornerRadius = 4
            button!.clipsToBounds = true
            button!.setBackgroundImage(UIImage.from(color: button!.backgroundColor!), for: .normal)
            button!.setBackgroundImage(UIImage.from(color: button!.tintColor!), for: .highlighted)
        }
        
        countdownTimer.delegate = self
        
        loadPreferences()
    }
    
    func loadPreferences() {
        intervalTextField.text = String(Preferences.interval)
        
        repetitionsCountTextField.text = String(Preferences.repetitionsCount)
        
        delayTextField.text = String(Preferences.delay)
        
        soundNameLabel.text = Preferences.soundName
        
        selectedSound = SoundsManager.sound(named: Preferences.soundName)
        
        updateCountdownTimer()
    }
    
    func updateDelayTextField(with delay: Int) {
        delayTextField.text = Self.delayFormatter.string(from: Date(timeIntervalSince1970: Double(delay)))
    }
    
    func updateRepetitionsCountTextField(with pastRepetitions: Int, totalRepetitions: Int) {
        repetitionsCountTextField.text = "\(pastRepetitions) / \(totalRepetitions)"
    }
    
    func updateCountdownTimer() {
        countdownTimer.set(
            intervalInMinutes: Preferences.interval,
            totalRepetitions: Preferences.repetitionsCount,
            delay: Preferences.delay)
    }
    
    func toggleControls(enabled: Bool) {
        intervalTextField.isEnabled = enabled
        repetitionsCountTextField.isEnabled = enabled
        delayTextField.isEnabled = enabled
        
        pickSoundButton.isEnabled = enabled
        playSoundSwitch.isEnabled = enabled
        vibrateSwitch.isEnabled = enabled
    }
    
    // MARK: Helpers
    
    func validateValues() -> Bool {
        guard let text = intervalTextField.text, !text.isEmpty, Int(text) ?? 0 != 0 else {
            showAlert(with: "Укажите интервал")
            return false
        }
        
        guard let text = repetitionsCountTextField.text, !text.isEmpty, Int(text) ?? 0 != 0 else {
            showAlert(with: "Укажите количество повторений")
            return false
        }
        
        guard let text = delayTextField.text, !text.isEmpty else {
            showAlert(with: "Укажите задержку")
            return false
        }
        
        guard let text = soundNameLabel.text, !text.isEmpty else {
            showAlert(with: "Выберите звук")
            return false
        }
        
        guard playSoundSwitch.isOn || vibrateSwitch.isOn else {
            showAlert(with: "Включите звук или вибрацию")
            return false
        }
        
        return true
    }
    
    func showAlert(with message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Продолжить", style: .default))
        present(alert, animated: true)
    }
    
    func resetTimer() {
        countdownTimer.reset()
        
        loadPreferences()
        
        runButton.setTitle("Запуск", for: .normal)
        
        toggleControls(enabled: true)
    }
    
    func playSoundIfAllowed(twice: Bool = false) {
        if playSoundSwitch.isOn {
            SoundPlayer.play(selectedSound!, twice: twice)
        }
    }
    
    func vibrationDidEnd() {
        
    }
    
    func vibrateIfAllowed(_ completion: @escaping () -> Void) {
        guard vibrateSwitch.isOn else { return }
        
        vibrationCompletionCallback = completion
        
        // completion setup https://stackoverflow.com/a/37487088/3004003
        
        let _selfPtr = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, nil, nil, { sound, ptr in
            let _self = unsafeBitCast(ptr, to: MainViewController.self)
            _self.vibrationCompletionCallback?()
        }, _selfPtr)
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    // MARK: UI Events
    
    @IBAction func runButtonTouchUpInside(_ sender: UIButton) {
        if !countdownTimer.isRunning && !countdownTimer.wasPaused {
            // validate values at startup or after reset
            guard validateValues() else { return }
        }
        
        toggleControls(enabled: false)
        
        let isPausedTitle = (sender.currentTitle == "Пауза")
        let title = isPausedTitle ? "Запуск" : "Пауза"
        sender.setTitle(title, for: .normal)
        
        if isPausedTitle {
            countdownTimer.pause()
        } else {
            countdownTimer.resume()
        }
        
    }
    
    @IBAction func resetButtonTouchUpInside(_ sender: UIButton) {
        resetTimer()
    }
    
    @IBAction func playSoundSwitchValueChanged(_ sender: UISwitch) {
        Preferences.playsSound = sender.isOn
    }
    
    @IBAction func vibrateSwitchValueChanged(_ sender: UISwitch) {
        Preferences.vibrates = sender.isOn
    }
    
    @objc func textFieldDone(_ sender: UIBarButtonItem) {
        
        let isNextItem = (sender.title == "Далее")
        
        switch activeTextField {
            
        case intervalTextField:
            Preferences.interval = Int(intervalTextField.text ?? "0") ?? 0
            
            if isNextItem {
                repetitionsCountTextField.becomeFirstResponder()
            } else {
                view.endEditing(true)
            }
            
        case repetitionsCountTextField:
            Preferences.repetitionsCount = Int(repetitionsCountTextField.text ?? "0") ?? 0
            
            if isNextItem {
                delayTextField.becomeFirstResponder()
            } else {
                view.endEditing(true)
            }
            
        case delayTextField:
            Preferences.delay = Int(delayTextField.text ?? "0") ?? 0
            view.endEditing(true)
            
        default:
            view.endEditing(true)
        }
        
        updateCountdownTimer()
    }
    
}

extension MainViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
}

extension MainViewController : CountdownTimerDelegate {
    
    func countdownTimerDidUpdateCount(_ countdownTimer: CountdownTimer, count: Int) {
        updateDelayTextField(with: count)
    }
    
    func countdownTimerDidUpdateRepetitions(_ countdownTimer: CountdownTimer, pastRepetitions: Int, totalRepetitions: Int) {
        updateRepetitionsCountTextField(with: pastRepetitions, totalRepetitions: totalRepetitions)
        playSoundIfAllowed()
        vibrateIfAllowed {}
    }
    
    func countdownTimerDidEndCounting(_ countdownTimer: CountdownTimer) {
        resetTimer()
        playSoundIfAllowed(twice: true)
        
        vibrateIfAllowed {
            self.vibrateIfAllowed {}
        }
    }
}

extension MainViewController : SoundsTableViewControllerDelegate {
    
    func soundsTableViewControllerDidSelectSound(_ viewController: SoundsTableViewController, sound: Sound) {
        selectedSound = sound
        soundNameLabel.text = sound.name
        Preferences.soundName = sound.name
    }
    
}

extension UIImage {
    /// https://stackoverflow.com/a/24615631/3004003
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

