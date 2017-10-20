//
//  KYCStep3ViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9/15/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import WalletCore
import RxSwift
import RxCocoa

class KYCStep3ViewController: UIViewController, KYCStepBinder {
    @IBOutlet weak var photoPlaceholder: KYCPhotoPlaceholderView!
    
    let disposeBag = DisposeBag()
    var documentsViewModel: KYCDocumentsViewModel!
    var documentsUploadViewModel: KycUploadDocumentsViewModel!
    
    lazy var loadingViewModel: LoadingViewModel = self.loadingViewModelFactory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoPlaceholder.hintLabel.text = Localize("kyc.process.titles.address")
        photoPlaceholder.imageView.image = #imageLiteral(resourceName: "kycAddress")
        bindKYC(disposedBy: disposeBag)
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

extension KYCStep3ViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: Localize("kyc.process.tabs.address"))
    }
}

extension KYCStep3ViewController: KYCDocumentTypeAware {
    var kYCDocumentType: KYCDocumentType{
        return .proofOfAddress
    }
}

extension KYCStep3ViewController: KYCPhotoPlaceholder {}
