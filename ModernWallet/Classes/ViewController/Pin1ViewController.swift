//
//  PinViewController.swift
//  ModernMoney
//
//  Created by Nacho Nachev on 28.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit

class Pin1ViewController: UIViewController {
    
    static var createPinViewController: Pin1ViewController {
        let viewController = Pin1ViewController(nibName: "Pin1ViewController", bundle: nil)
        viewController.mode = .createPin
        return viewController
    }
    
    @IBOutlet private var keyboardButtons: [UIButton]!
    @IBOutlet private weak var touchIdButton: UIButton!
    @IBOutlet private weak var forgotPinButton: UIButton!

    var permitedTriesCount = 3

    private enum Mode {
        case createPin
        case enterPin
    }
    
    private var mode: Mode = .enterPin
    
    private var triesLeftCount = 3
    
    private var digits = [String]()
    
    private var pins = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        triesLeftCount = permitedTriesCount
    }
    
    // MARK: IBActions
    
    @IBAction private func digitTapped(_ digitButton: UIButton) {
        digits.append("\(digitButton.tag)")
        if digits.count == 4 {
            pinEntered()
        }
    }
    
    // MARK: Private
    
    private func pinEntered() {
        let pin = digits.joined(separator: "")
        switch mode {
        case .createPin:
            pins.append(pin)
            checkIfPinsMatch()
        case .enterPin:
            break
        }
    }
    
    private func checkIfPinsMatch() {
        guard pins.count == 2 else { return }
        guard pins[0] == pins[1] else {
            shakeKeyboard()
            reset()
            return
        }
    }
    
    private func shakeKeyboard() {
        
    }

    private func reset() {
        
    }
    
}
