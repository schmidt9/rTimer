//
//  MainViewController.swift
//  rTimer
//
//  Created by Alexander Kormanovsky on 18.12.2022.
//

import UIKit

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

    private var isDelayTimer = true
    private var isMainTimer = false
    private var wasReset = true
    private var delay = 0
    private var interval = 0
    private var totalRepetitions = 0
    private var repetitions = 0

    private var countdownTimer = CountdownTimer()

    private static var delayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "mm:ss"

        return formatter
    }()

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
        
        intervalTextField.text = String(Preferences.interval)
        
        repetitionsCountTextField.text = String(Preferences.repetitionsCount)
        
        delayTextField.text = String(Preferences.delay)
        
        soundNameLabel.text = Preferences.soundName
        
        for textField in [intervalTextField, repetitionsCountTextField, delayTextField] {
            let toolbar = UIToolbar()
            let doneItem = UIBarButtonItem(title: "Применить", style: .done, target: self, action: #selector(textFieldDone(_:)))
            let spacingItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbar.items = [spacingItem, doneItem]
            toolbar.sizeToFit()
            textField?.inputAccessoryView = toolbar
        }

        countdownTimer.delegate = self
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

    func initValues() {
        if wasReset {
            interval = Int(intervalTextField.text ?? "0") ?? 0 * 60
            repetitions = Int(repetitionsCountTextField.text ?? "0") ?? 0
            totalRepetitions = repetitions
            delay = Int(delayTextField.text ?? "0") ?? 0
        } else {
            interval = Preferences.interval
            delay = Preferences.delay
            
        }
    }

    func showAlert(with message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Продолжить", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: UI Events

    @IBAction func runButtonTouchUpInside(_ sender: UIButton) {
        if !countdownTimer.isRunning && !countdownTimer.wasPaused {
            // validate values at startup or after reset
            guard validateValues() else { return }
        }

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
        isDelayTimer = true
        isMainTimer = false
    }
    
    @IBAction func playSoundSwitchValueChanged(_ sender: UISwitch) {
        Preferences.playsSound = sender.isOn
    }
    
    @IBAction func vibrateSwitchValueChanged(_ sender: UISwitch) {
        Preferences.vibrates = sender.isOn
    }
    
    @objc func textFieldDone(_ sender: UIBarButtonItem) {
        switch activeTextField {
            
        case intervalTextField:
            Preferences.interval = Int(intervalTextField.text ?? "0") ?? 0
            repetitionsCountTextField.becomeFirstResponder()
            
        case repetitionsCountTextField:
            Preferences.repetitionsCount = Int(repetitionsCountTextField.text ?? "0") ?? 0
            delayTextField.becomeFirstResponder()
            
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
    }

    func countdownTimerDidEndCounting(_ countdownTimer: CountdownTimer) {
        // TODO: impl
    }
}

extension MainViewController : SoundsTableViewControllerDelegate {
    
    func soundsTableViewControllerDidSelectSound(_ viewController: SoundsTableViewController, soundName: String) {
        soundNameLabel.text = soundName
        Preferences.soundName = soundName
    }
    
}

