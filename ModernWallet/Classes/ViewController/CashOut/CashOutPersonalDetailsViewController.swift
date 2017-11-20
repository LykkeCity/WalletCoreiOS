//
//  CashOutPersonalDetailsViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 24.10.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class CashOutPersonalDetailsViewController: UIViewController {
    
     @IBOutlet internal weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet fileprivate weak var nameTextField: UITextField!
    @IBOutlet fileprivate weak var reasonTextField: UITextField!
    @IBOutlet fileprivate weak var notesTextField: UITextField!
    
    @IBOutlet fileprivate weak var nextButton: UIButton!
    
    var cashOutViewModel: CashOutViewModel!
    
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        subtitleLabel.text = Localize("cashOut.newDesign.personalDetails")
        nameTextField.placeholder = Localize("cashOut.newDesign.name")
        reasonTextField.placeholder = Localize("cashOut.newDesign.transactionReason")
        notesTextField.placeholder = Localize("cashOut.newDesign.additionalNotes")
        nextButton.setTitle(Localize("newDesign.next"), for: .normal)
        
        let generalViewModel = cashOutViewModel.generalViewModel
        
        (nameTextField.rx.textInput <-> generalViewModel.name)
            .disposed(by: disposeBag)
        
        (reasonTextField.rx.textInput <-> generalViewModel.transactionReason)
            .disposed(by: disposeBag)
        
        (notesTextField.rx.textInput <-> generalViewModel.additionalNotes)
            .disposed(by: disposeBag)
        
        let isFormValidDriver = generalViewModel.isValid.asDriver(onErrorJustReturn: false)
        
        isFormValidDriver
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        setupFormUX(disposedBy: disposeBag)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NextStep" {
            guard let vc = segue.destination as? CashOurBankAccountDetailsViewController else {
                return
            }
            vc.cashOutViewModel = cashOutViewModel
        }
    }

}

extension CashOutPersonalDetailsViewController: InputForm {
    
    var submitButton: UIButton! {
        return nextButton
    }
    
    var textFields: [UITextField] {
        return [
            nameTextField,
            reasonTextField,
            notesTextField
        ]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
    
}
