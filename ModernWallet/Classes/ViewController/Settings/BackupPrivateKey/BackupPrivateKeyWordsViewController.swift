//
//  BackupPrivateKeyWordsViewController.swift
//  ModernWallet
//
//  Created by Nacho Nachev on 21.11.17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore

class BackupPrivateKeyWordsViewController: UIViewController {
    
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var prevButton: UIButton!
    @IBOutlet private weak var pageLabel: UILabel!
    @IBOutlet private weak var nextButton: UIButton!

    fileprivate let words: [String] = {
        if let words = LWPrivateKeyManager.shared().privateKeyWords() as? [String] {
            return words;
        }
        return LWPrivateKeyManager.generateSeedWords12() as! [String]
    }()
    
    private var selectedWordIndex = 0
    fileprivate var currentWordIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        nextButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        nextButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)

        messageLabel.text = Localize("backup.newDesign.writeDownWords")
        prevButton.setTitle(Localize("backup.newDesign.prevWord"), for: .normal)
        nextButton.setTitle(Localize("backup.newDesign.nextWord"), for: .normal)
        
        updatePageLabel()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.itemSize = collectionView.bounds.size
    }
    
    // MARK: - IBActions
    
    @IBAction private func prevButtonTapped() {
        selectedWordIndex = max(selectedWordIndex - 1, 0)
        let indexPath = IndexPath(row: selectedWordIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        prevButton.isEnabled = selectedWordIndex > 0
    }
    
    @IBAction private func nextButtonTapped() {
        let nextWordIndex = selectedWordIndex + 1
        guard nextWordIndex < words.count else {
//            performSegue(withIdentifier: "WriteWords", sender: nil)
            return
        }
        prevButton.isEnabled = true
        selectedWordIndex = nextWordIndex
        let indexPath = IndexPath(row: nextWordIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Private
    
    fileprivate func updatePageLabel() {
        let pageFormat = Localize("backup.newDesign.wordPageFmt") ?? "%d OF %d"
        pageLabel.text = String(format: pageFormat, currentWordIndex + 1, words.count)
    }

}

extension BackupPrivateKeyWordsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordCell", for: indexPath)
        
        guard let wordLabel = cell.contentView.subviews.first as? UILabel else {
            return cell
        }
        wordLabel.text = words[indexPath.row]
        return cell
    }
    
}

extension BackupPrivateKeyWordsViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let wordIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width + 0.5)
        if wordIndex != currentWordIndex {
            currentWordIndex = wordIndex
            updatePageLabel()
        }
    }
    
}
