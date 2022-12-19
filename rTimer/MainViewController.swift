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

    private var timer: Timer?
    private var isDelayTimer = true
    private var isMainTimer = false
    private var delay = 0

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

        delay = Preferences.delay
    }

    func updateDelayTextField(with delay: Int) {
        delayTextField.text = Self.delayFormatter.string(from: Date(timeIntervalSince1970: Double(delay)))
    }

    // MARK: Timer

    func startTimer() {
        timer?.invalidate()
        timer = Timer(
                timeInterval: 1.0,
                target: self,
                selector: #selector(timerFired(_ :)),
                userInfo: nil,
                repeats: true)
        RunLoop.current.add(timer!, forMode: .default)
    }

    func stopTimer() {

    }

    @objc func timerFired(_ sender: Timer) {
        if isDelayTimer {
            if delay == 0 {
                isDelayTimer = false
                isMainTimer = true
            } else {
                delay -= 1
            }

            updateDelayTextField(with: delay)
        }
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
    
    // MARK: UI Events

    @IBAction func runButtonTouchUpInside(_ sender: UIButton) {
        guard validateValues() else { return }

        let isPaused = (sender.currentTitle == "Пауза")
        let title = isPaused ? "Запуск" : "Пауза"
        sender.setTitle(title, for: .normal)

        startTimer()
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
    }
    
}

extension MainViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
}

extension MainViewController : SoundsTableViewControllerDelegate {
    
    func soundsTableViewControllerDidSelectSound(_ viewController: SoundsTableViewController, soundName: String) {
        soundNameLabel.text = soundName
        Preferences.soundName = soundName
    }
    
}

