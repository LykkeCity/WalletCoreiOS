//
//  KYCStep2ViewController.swift
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

class KYCStep2ViewController: UIViewController, KYCStepBinder {
    @IBOutlet weak var photoPlaceholder: KYCPhotoPlaceholderView!
    
    let disposeBag = DisposeBag()
    var documentsViewModel: KYCDocumentsViewModel!
    var documentsUploadViewModel: KycUploadDocumentsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoPlaceholder.hintLabel.text = Localize("kyc.process.titles.passport")
        photoPlaceholder.imageView.image = #imageLiteral(resourceName: "kycPassport")
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

extension KYCStep2ViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: Localize("kyc.process.tabs.passport"))
    }
}

extension KYCStep2ViewController: KYCDocumentTypeAware {
    var kYCDocumentType: KYCDocumentType{
        return .idCard
    }
}

extension KYCStep2ViewController: KYCPhotoPlaceholder {}
