//
//  KYCPhotoFailedViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 10/2/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class KYCPhotoFailedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var documentsModel: LWKYCDocumentsModel?
    
    typealias TableCellModel = (type: KYCDocumentType, message: String?)
    
    var statuses: [TableCellModel] {
        guard let documentsModel = self.documentsModel else {return []}
        
        return [
            KYCDocumentType.selfie,
            KYCDocumentType.idCard,
            KYCDocumentType.proofOfAddress
        ]
        .filter{documentsModel.status(for: $0).isRejected}
        .map{(
            type: $0,
            message: documentsModel.comment(for: $0)
        )}
    }
    
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable.just(statuses)
            .bind(to: tableView.rx.items(cellIdentifier: "KYCPhotoFailedTableViewCell", cellType: KYCPhotoFailedTableViewCell.self)) { (row, element, cell) in
                cell.title.text = element.type.failedPhotoTitle
                cell.message.text = element.message
            }
            .disposed(by: disposeBag)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onCancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
