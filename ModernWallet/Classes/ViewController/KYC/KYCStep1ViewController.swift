//
//  KYCStep1ViewController.swift
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

class KYCStep1ViewController: UIViewController, KYCStepBinder {

    @IBOutlet weak var photoPlaceholder: KYCPhotoPlaceholderView!
    
    let disposeBag = DisposeBag()
    var documentsViewModel: KYCDocumentsViewModel!
    var documentsUploadViewModel: KycUploadDocumentsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoPlaceholder.hintLabel.text = Localize("kyc.process.titles.selfie")
        photoPlaceholder.imageView.image = #imageLiteral(resourceName: "kycSelfie")
        
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


extension KYCStep1ViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: Localize("kyc.process.tabs.selfie"))
    }
}

extension KYCStep1ViewController: KYCDocumentTypeAware {
    var kYCDocumentType: KYCDocumentType{
        return .selfie
    }
}

extension KYCStep1ViewController: KYCPhotoPlaceholder {}


