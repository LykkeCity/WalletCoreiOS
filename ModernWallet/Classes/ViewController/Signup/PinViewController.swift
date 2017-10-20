//
//  PinViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 9/12/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa

@objc protocol PinViewControllerDelegate: class {
    func isPinCorrect(_ success: Bool, pinController: PinViewController)
    @objc optional func isTouchIdCorrect(_ success: Bool, pinController: PinViewController)
    @objc optional  func changeTextLabel(_ txtLabel: String?)
}

protocol PinAwarePresenter {
    var requirePinForTrading: Bool{get}
}

class PinViewController: UIViewController {
    
    @IBOutlet weak var pinButton1: UIButton!
    @IBOutlet weak var pinButton2: UIButton!
    @IBOutlet weak var pinButton3: UIButton!
    @IBOutlet weak var pinButton4: UIButton!
    @IBOutlet weak var numButton1: UIButton!
    @IBOutlet weak var numButton2: UIButton!
    @IBOutlet weak var numButton3: UIButton!
    @IBOutlet weak var numButton4: UIButton!
    @IBOutlet weak var numButton5: UIButton!
    @IBOutlet weak var numButton6: UIButton!
    @IBOutlet weak var numButton7: UIButton!
    @IBOutlet weak var numButton8: UIButton!
    @IBOutlet weak var numButton9: UIButton!
    @IBOutlet weak var numButton0: UIButton!
    @IBOutlet weak var touchIdButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var numberHeight: NSLayoutConstraint!
    @IBOutlet weak var numberWidth: NSLayoutConstraint!
    
    weak var delegate:PinViewControllerDelegate?
    var twoVerifications: Bool = false
    var isTouchIdHidden: Bool = false
    var myPin = ""
    var counter = 0
    
    var triggerButton: UIButton = UIButton(type: UIButtonType.custom)
    
    lazy var viewModel : PinGetViewModel={
        return PinGetViewModel(submit: self.triggerButton.rx.tap.asObservable() )
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.clear
        
        if LWFingerprintHelper.isFingerprintAvailable() && !isTouchIdHidden {
            pinButtonPressedFingerPrint()
        }

        touchIdButton.isHidden = isTouchIdHidden
        
        setUpPinViewModel()
        
        if Display.typeIsLike == .iphone5 {
            numberHeight.constant = 42.0
            numberWidth.constant = 42.0
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
////        [self.navigationController.navigationBar setTranslucent:NO];
//        self.navigationController?.navigationBar.isTranslucent = true
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addPinAction(_ sender:UIButton) {
        
        switch false {
        case pinButton1.isSelected:
            pinButton1.isSelected = true
            pinButton1.tag = Int((sender.titleLabel?.text)!)!
        case pinButton2.isSelected:
            pinButton2.isSelected = true
            pinButton2.tag = Int((sender.titleLabel?.text)!)!
        case pinButton3.isSelected:
            pinButton3.isSelected = true
            pinButton3.tag = Int((sender.titleLabel?.text)!)!
        case pinButton4.isSelected:
            pinButton4.isSelected = true
            pinButton4.tag = Int((sender.titleLabel?.text)!)!
            if twoVerifications {
                if myPin != "" {
                    checkPinTwoTimeVerification()
                }
                else {
                    firstTimeAddingPin()
                }
            }
            else {
                checkPinOneTimeVerification()
            }
        default:
            print("Nothing happens")
        }
    }
    
    @IBAction func deletePinAction(_ sender:UIButton) {
        
        switch true {
        case pinButton4.isSelected:
            pinButton4.isSelected = false
        case pinButton3.isSelected:
            pinButton3.isSelected = false
        case pinButton2.isSelected:
            pinButton2.isSelected = false
        case pinButton1.isSelected:
            pinButton1.isSelected = false
        default:
            print("Nothing happens")
        }
    }
    
    func shakePinView() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x:containerView.center.x - 10, y:containerView.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x:containerView.center.x + 10, y:containerView.center.y))
        containerView.layer.add(animation, forKey: "position")
    }
    
    func removeAllPins() {
        pinButton1.isSelected = false
        pinButton2.isSelected = false
        pinButton3.isSelected = false
        pinButton4.isSelected = false
        
        if counter >= 3 && twoVerifications
        {
            resetFirstPin()
        }
    }
    

    
    func firstTimeAddingPin() {
        myPin = String(format: "%d%d%d%d", pinButton1.tag, pinButton2.tag, pinButton3.tag, pinButton4.tag)
        delegate?.changeTextLabel!(Localize("pin.verify.title"))
        removeAllPins()
    }
    
    func resetFirstPin() {
        myPin = ""
        counter = 0
        delegate?.changeTextLabel!(Localize("pin.create.new.title"))
    }
    
    
    func checkPinOneTimeVerification() {
        
        let keyManager = LWKeychainManager.instance()
        let currentPin = String(format: "%d%d%d%d", pinButton1.tag, pinButton2.tag, pinButton3.tag, pinButton4.tag)
        
        if let storedPin = keyManager?.pin() {
            if storedPin == currentPin {
                delegate?.isPinCorrect(true, pinController: self)
            }
            else {
                shakePinView()
                removeAllPins()
            }
        }
        else {
            viewModel.pin.value = currentPin
            self.triggerButton.sendActions(for: .touchUpInside)
        }
        
        //        if storedPin?.pin() == currentPin {
//        if "5555" == currentPin {
            //            createPrivateKey()
            //            getClientCode()
//            delegate?.isPinCorrect(true, pinController: self)
          //  dismisVC()
            //            triggerButton.sendActions(for: .touchUpInside)
//        }
//        else {
//            shakePinView()
//            removeAllPins()
//        }
    }
    
    func checkPinTwoTimeVerification() {
        
        let currentPin = String(format: "%d%d%d%d", pinButton1.tag, pinButton2.tag, pinButton3.tag, pinButton4.tag)
        counter += 1
        
        if myPin == currentPin {
            
            delegate?.isPinCorrect(true, pinController: self)
        }
        else {
            shakePinView()
            removeAllPins()
        }
    }
    
    func pinButtonPressedFingerPrint() {
        LWFingerprintHelper.validateFingerprintTitle(Localize("auth.validation.fingerpring"), ok: {
            self.delegate?.isTouchIdCorrect?(true, pinController: self)
        }, bad: {
            self.delegate?.isTouchIdCorrect?(false, pinController: self)
            print("Something went wrong")
        }) {
            self.delegate?.isTouchIdCorrect?(false, pinController: self)
            print("Something went wrong")
        }
    }
    
    @IBAction func touchIdAction(_ sender: UIButton) {
        if LWFingerprintHelper.isFingerprintAvailable()  && !isTouchIdHidden {
            pinButtonPressedFingerPrint()
        }
    }
    
    func setUpPinViewModel() {
        
        viewModel.loading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterError()
            .subscribe(onNext: {[weak self] errorData in
                self?.delegate?.isPinCorrect(false, pinController: self!)
                
            })
            .disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterSuccess()
            .subscribe(onNext: {[weak self] pack in
                
                //gonext
                if(pack.isPassed == true)
                {
                    self?.delegate?.isPinCorrect(true, pinController: self!)
                }
                else{
                    self?.shakePinView()
                    self?.removeAllPins()
                }
            })
            .disposed(by: disposeBag)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
