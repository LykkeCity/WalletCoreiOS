//
//  ConfirmationViewController.swift
//  ModernMoney
//
//  Created by Ivan Stoykov on 8.08.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import WalletCore
import WebKit

protocol ConfirmationDelegate: class {
    func didConfirm(withViewController viewController: ConfirmationViewController)
}

class ConfirmationViewController: UIViewController {
    
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var firstAsset: UILabel!
    @IBOutlet weak var secondAsset: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    weak var delegate: ConfirmationDelegate?
    
    var first: String?
    var second: String?
    var firstLabelText: String?
    var secondLabelText: String?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        cancel.rx.tap.asObservable()
            .bind { [weak self] in self?.dismiss(animated: true, completion: nil) }
            .disposed(by: disposeBag)
        
        confirmButton.rx.tap.asObservable()
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let strongSelf = self else { return Observable<Void>.never() }
                return PinViewController.presentOrderPinViewController(from: strongSelf, title: Localize("newDesign.enterPin"), isTouchIdEnabled: true)
            }
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.didConfirm(withViewController: strongSelf)
            })
            .disposed(by: disposeBag)
        
        // Do any additional setup after loading the view.
        
        updateUI()
    }
    
    func updateUI(){
        
        firstAsset.text = first
        secondAsset.text = second
        firstLabel.text = firstLabelText
        secondLabel.text = secondLabelText
        infoLabel.text = Localize("confirm.newDesign.labelInfo")
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
