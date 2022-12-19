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
    
    func setup() {
        
        timerContainerView.layer.cornerRadius = 8
        
        intervalTextField.text = String(Preferences.interval)
        
        repetitionsCountTextField.text = String(Preferences.repetitionsCount)
        
        delayTextField.text = String(Preferences.delay)
        
        soundNameLabel.text = Preferences.soundName
        
        for textField in [intervalTextField, repetitionsCountTextField, delayTextField] {
            let toolbar = UIToolbar()
            let doneItem = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(textFieldDone(_:)))
            let spacingItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbar.items = [spacingItem, doneItem]
            toolbar.sizeToFit()
            textField?.inputAccessoryView = toolbar
        }
    }

    // MARK: Timer

    func validateValues() {
        guard let text = intervalTextField.text, !text.isEmpty, Int(text) ?? 0 != 0 else {
            showAlert(with: "Укажите интервал")
            return
        }

        guard let text = repetitionsCountTextField.text, !text.isEmpty, Int(text) ?? 0 != 0 else {
            showAlert(with: "Укажите количество повторений")
            return
        }

        guard let text = delayTextField.text, !text.isEmpty else {
            showAlert(with: "Укажите задержку")
            return
        }

        guard let text = soundNameLabel.text, !text.isEmpty else {
            showAlert(with: "Выберите звук")
            return
        }

        guard playSoundSwitch.isOn || vibrateSwitch.isOn else {
            showAlert(with: "Включите звук или вибрацию")
            return
        }
    }

    // MARK: Helpers

    func showAlert(with message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.actions = [UIAlertAction(title: "Продолжить", style: .default)]
        present(alert, animated: true)
    }
    
    // MARK: UI Events

    @IBAction func runButtonTouchUpInside(_ sender: UIButton) {
    }
    
    @IBAction func resetButtonTouchUpInside(_ sender: UIButton) {
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
            Preferences.interval = Int(intervalTextField.text ?? "0")!
            repetitionsCountTextField.becomeFirstResponder()
            
        case repetitionsCountTextField:
            Preferences.repetitionsCount = Int(repetitionsCountTextField.text ?? "0")!
            delayTextField.becomeFirstResponder()
            
        case delayTextField:
            Preferences.delay = Int(delayTextField.text ?? "0")!
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

