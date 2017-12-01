//
//  BackupPrivateKeyStartViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 20.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import WalletCore

class BackupPrivateKeyStartViewController: UIViewController {

    @IBOutlet private weak var makeBackupLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var startButton: UIButton!
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeBackupLabel.text = Localize("backup.newDesign.makeBackup")
        infoLabel.text = Localize("backup.newDesign.backupInfo")
        startButton.setTitle(Localize("backup.newDesign.readyToWrite"), for: .normal)
    }
    
    // MARK: IBActions
    
    @IBAction func startTapped() {
        let pinVC = PinViewController.enterPinViewController(title: Localize("backup.newDesign.forAdditionalSecurity"),
                                                              isTouchIdEnabled: true)
        pinVC.complete
            .bind(onNext: { [weak self] pinPassed in
                guard pinPassed else { return }
                self?.performSegue(withIdentifier: "StartBackup", sender: nil)
            })
            .disposed(by: disposeBag)
        present(pinVC, animated: true)
    }

}
