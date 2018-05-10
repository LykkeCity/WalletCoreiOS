//
//  AssetDisclaimerViewController.swift
//  ModernMoney
//
//  Created by Georgi Stanev on 10.05.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class AssetDisclaimerViewController: UIViewController {

    
    @IBOutlet weak var acceptedButton: UIButton!
    @IBOutlet weak var `continue`: UIButton!
    @IBOutlet weak var cancel: UIButton!
    
    // move this variable to a dedicated view model
    let accepted = Variable(false)
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancel.rx.tap.asObservable()
            .bind { [weak self] in self?.dismiss(animated: true, completion: nil) }
            .disposed(by: disposeBag)

        accepted.asDriver()
            .map{ $0 ? #imageLiteral(resourceName: "CheckboxChecked") : #imageLiteral(resourceName: "CheckboxUnchecked") }
            .drive(acceptedButton.rx.image(for: .normal))
            .disposed(by: disposeBag)
        
        acceptedButton.rx.tap.asDriver()
            .map{ [accepted] in !accepted.value }
            .drive(accepted)
            .disposed(by: disposeBag)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
