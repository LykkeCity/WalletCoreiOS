//
//  BackupPrivateKeyCheckWordsViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 22.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class BackupPrivateKeyCheckWordsViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var typingTextField: UITextField!
    @IBOutlet private weak var confirmButton: UIButton!
    
    var words: [String]!
    
    lazy var viewModel: BackupPrivateKeyViewModel = {
        let font = UIFont(name: "Geomanist", size: 20.0)
        let params = BackupPrivateKeyViewModel.Params(words: self.words, font: font, typingColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), correctColor: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), wrongColor: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))
        return BackupPrivateKeyViewModel(params: params, authManager: LWRxAuthManager.instance)
    }()
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        typingTextField.delegate = self
        
        scrollView?.subscribeKeyBoard(withDisposeBag: disposeBag)
        scrollView?.keyboardDismissMode = .onDrag
        
        typingTextField.rx.text
            .map { [typingTextField] in return ($0, typingTextField!.isEditing) }
            .asDriver(onErrorJustReturn: (nil, false))
            .drive(viewModel.typedText)
            .disposed(by: disposeBag)
        
        viewModel.colorizedText
            .subscribe(onNext: { [typingTextField] (attributedText) in
                typingTextField?.setAttributedTextAndPreserveState(attributedText)
            })
            .disposed(by: disposeBag)
        
        
        viewModel.areAllWordsCorrect
            .asDriver(onErrorJustReturn: false)
            .drive(confirmButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.areAllWordsCorrect
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [typingTextField, viewModel] _ in
                typingTextField?.resignFirstResponder()
                viewModel.confirmTrigger.onNext(())
            })
            .disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .bind { [viewModel] in viewModel.confirmTrigger.onNext(()) }
            .disposed(by: disposeBag)
        
        viewModel.loadingViewModel.isLoading
            .asDriver(onErrorJustReturn: false)
            .drive(rx.loading)
            .disposed(by: disposeBag)
        
        viewModel.errors
            .asDriver(onErrorJustReturn: [:])
            .drive(rx.error)
            .disposed(by: disposeBag)
        
        viewModel.success
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.performSegue(withIdentifier: "ShowComplete", sender: nil)
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

extension BackupPrivateKeyCheckWordsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        let wordsCount = newText.components(separatedBy: " ").count
        return newText.range(of: "  ") == nil && wordsCount <= words.count
    }
}

extension UITextField {
    
    fileprivate func setAttributedTextAndPreserveState(_ attributedText: NSAttributedString) {
        let selectedTextRange = self.selectedTextRange
        guard let bounds = self.textInputView.superview?.bounds else { return }
        self.attributedText = attributedText
        self.textInputView.superview?.bounds = bounds
        self.selectedTextRange = selectedTextRange
    }
    
}
