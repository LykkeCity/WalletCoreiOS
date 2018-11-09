//
//  KYCTabStripViewController.swift
//  ModernWallet
//
//  Created by Georgi Stanev on 9/15/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa
import XLPagerTabStrip
import AlamofireImage

class KYCTabStripViewController: BaseButtonBarPagerTabStripViewController<KYCTabCollectionViewCell>,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var nextStepButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var picStatusContainer: UIStackView!
    @IBOutlet weak var picStatusTitle: UILabel!
    @IBOutlet weak var picStatusDescr: UILabel!
    
    private var pickedImage = Variable<UIImage?>(nil)
    
    private let disposeBag = DisposeBag()
    
    lazy var documentsViewModel: KYCDocumentsViewModel = {
        return KYCDocumentsViewModel(
            trigger: self.documentsUploadViewModel.image.asObservable()
                .filterNil()
                .map{_ in Void()}
                .startWith(Void()),
            forAsset: LWRxAuthManager.instance.baseAsset.request()
                .debug("JORO: lazy LWRxAuthManager base")
        )
    }()
    
    lazy var documentsUploadViewModel: KycUploadDocumentsViewModel = {
        return KycUploadDocumentsViewModel(
            forImage: self.pickedImage.asObservable(),
            withType: self.documentType
        )
    }()
    
    
    lazy var loadingViewModel: LoadingViewModel = {
        return LoadingViewModel([
            self.documentsUploadViewModel.loadingViewModel.isLoading,
            self.documentsViewModel.loadingViewModel.isLoading
        ])
    }()
    
    let documentType = Variable<KYCDocumentType?>(nil)
    
    let purpleInspireColor = UIColor(red:0.13, green:0.03, blue:0.25, alpha:1.0)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buttonBarItemSpec = ButtonBarItemSpec.nibFile(nibName: "KYCTabCollectionViewCell", bundle: Bundle(for: KYCTabCollectionViewCell.self), width: { (cell: IndicatorInfo) -> CGFloat in
            return 55.0
        })
    }
    
    fileprivate lazy var controllers: [UIViewController] = {
        guard let storyboard = self.storyboard else {return []}
        
        let step1 = storyboard.instantiateViewController(withIdentifier: "kycStep1VC") as! KYCStep1ViewController
        let step2 = storyboard.instantiateViewController(withIdentifier: "kycStep2VC") as! KYCStep2ViewController
        let step3 = storyboard.instantiateViewController(withIdentifier: "kycStep3VC") as! KYCStep3ViewController
        
        step1.documentsViewModel = self.documentsViewModel
        step2.documentsViewModel = self.documentsViewModel
        step3.documentsViewModel = self.documentsViewModel
        
        step1.documentsUploadViewModel = self.documentsUploadViewModel
        step2.documentsUploadViewModel = self.documentsUploadViewModel
        step3.documentsUploadViewModel = self.documentsUploadViewModel
        
        return [step1, step2, step3]
    }()
    
    override func viewDidLoad() {
        // change selected bar color
        setup()
        
        super.viewDidLoad()
        
        
        
        // bind view models
        documentsUploadViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        documentsViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        documentType.asObservable()
            .bindToDisable(button: nextStepButton)
            .disposed(by: disposeBag)
        
        // bind documents and doc type
        Observable
            .combineLatest(documentsViewModel.documents, documentType.asObservable().filterNil())
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        // bind image picker presenter
        let imagePicker = factoryImagePickerController()
        
        cameraButton.rx.tap
            .bind{ [weak self] in
                self?.present(imagePicker, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        //bind errors
        Driver.merge(
            documentsViewModel.error,
            documentsUploadViewModel.error
        )
        .drive(onNext: {[weak self] error in
            self?.show(error: error)
        })
        .disposed(by: disposeBag)
        
        // bind loading
        loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.pickedImage.value = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return controllers
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        self.documentType.value = self.currentKYCDocumentType
    }

    override func configure(cell: KYCTabCollectionViewCell, for indicatorInfo: IndicatorInfo) {
        cell.label.text = indicatorInfo.title
        cell.image.image = indicatorInfo.image
        cell.image.isHidden = indicatorInfo.image == nil
    }
    
    private func setup() {
        guard let font = UIFont(name: "Geomanist-Book", size: 14) else {return}
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = .white
        settings.style.buttonBarItemFont = font
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .white
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { (oldCell: KYCTabCollectionViewCell?, newCell: KYCTabCollectionViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.alpha = 0.5
            newCell?.label.alpha = 1.0
        }
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

// MARK:- View Model extensions
fileprivate extension KYCDocumentsViewModel {
    func bind(toViewController vc: KYCTabStripViewController) -> [Disposable] {
        return [
            documents.subscribeToFillIcon(forType: .selfie, inButtonBar: vc.buttonBarView),
            documents.subscribeToFillIcon(forType: .idCard, inButtonBar: vc.buttonBarView),
            documents.subscribeToFillIcon(forType: .proofOfAddress,  inButtonBar: vc.buttonBarView),
            documents
                .filterAnyRejected()
                .mapToFailedViewController(withStoryBoard: vc.storyboard)
                .take(1) // show photo failed just once
                .subscribe(onNext: {[weak vc] controller in
                    vc?.present(controller, animated: true, completion: nil)
                }),
            
            documents
                .filterAllUploadedOrApproved()
                .subscribe(onNext: {[weak vc] _ in
                    vc?.dismiss(animated: true) {
                        NotificationCenter.default.post(name: .kycDocumentsUploadedOrApproved, object: nil)
                    }
                }
            ),
            
            vc.nextStepButton.rx.tap.asObservable()
                .withLatestFrom(documents)
                .subscribeToMoveNext(withVC: vc)
        ]
    }
}

fileprivate extension KycUploadDocumentsViewModel {
    func bind(toViewController vc: KYCTabStripViewController) -> [Disposable] {
        return [
            image.filterNil().driveToReplacePlaceHolder(inVC: vc)
        ]
    }
}

// MARK:- Computed properties
fileprivate extension KYCTabStripViewController {
    fileprivate var currentPhotoPlaceHolder: KYCPhotoPlaceholder? {
        guard let photoHolder = self.controllers[self.currentIndex] as? KYCPhotoPlaceholder else {return nil}
        return photoHolder
    }
    
    fileprivate var currentKYCDocumentType: KYCDocumentType? {
        guard let kycDocumentypeAware = self.controllers[self.currentIndex] as? KYCDocumentTypeAware else {return nil}
        return kycDocumentypeAware.kYCDocumentType
    }
}

// MARK:- RX Exensions
fileprivate extension ObservableType where Self.E == (LWKYCDocumentsModel, KYCDocumentType) {
    func bind(toViewController vc: KYCTabStripViewController) -> [Disposable] {
        return [
            mapToStatus()
                .map{ $0.buttonText }
                .bind(to: vc.cameraButton.rx.title),
            
            mapToStatus()
                .map{ !$0.isUploadedOrApproved }
                .bind(to: vc.picStatusContainer.rx.isHiddenAnimated),
            
            mapToStatus()
                .map{ $0.title }
                .bind(to: vc.picStatusTitle.rx.text),
            
            mapToStatus()
                .map{ $0.description }
                .bind(to: vc.picStatusDescr.rx.text),
            
            mapToStatus()
                .map{ $0.isUploadedOrApproved }
                .bind(to: vc.cameraButton.rx.isHiddenAnimated)
        ]
    }
}

fileprivate extension ObservableType where Self.E == LWKYCDocumentsModel {
    func filterAnyRejected() -> Observable<LWKYCDocumentsModel> {
        return filter{kycModel in
            kycModel.status(for: .selfie).isRejected ||
            kycModel.status(for: .idCard).isRejected ||
            kycModel.status(for: .proofOfAddress).isRejected
        }
    }
    
    func filterAllUploadedOrApproved() -> Observable<LWKYCDocumentsModel> {
        return filter{kycModel in
            kycModel.status(for: .selfie).isUploadedOrApproved &&
            kycModel.status(for: .idCard).isUploadedOrApproved &&
            kycModel.status(for: .proofOfAddress).isUploadedOrApproved
        }
    }
    
    func mapToFailedViewController(withStoryBoard storyboard: UIStoryboard?) -> Observable<KYCPhotoFailedViewController> {
        return map{[weak storyboard] documentsModel -> KYCPhotoFailedViewController? in
            guard let controller = storyboard?.instantiateViewController(withIdentifier: "kycPhotoFailedVC")
                as? KYCPhotoFailedViewController else {
                    return nil
            }
            
            controller.documentsModel = documentsModel
            return controller
        }.filterNil()
    }
    
    func subscribeToMoveNext(withVC vc: BaseButtonBarPagerTabStripViewController<KYCTabCollectionViewCell>) -> Disposable {
        return subscribe(onNext: {[weak vc] documentsModel -> Void in
            guard let vc = vc else {return}
            guard var nextDocType = KYCDocumentType.find(byIndex: vc.currentIndex)?.next else{return}
            
            //If next doctype is uploaded or approved go to one after the next one
            if [.uploaded, .approved].contains(documentsModel.status(for: nextDocType)), let furtherDocType = nextDocType.next {
                nextDocType = furtherDocType
            }
            
            guard vc.canMoveTo(index: nextDocType.index) else {return}
            vc.moveToViewController(at: nextDocType.index, animated: true)
        })
    }
}

extension ObservableType where Self.E == LWKYCDocumentsModel {
    func subscribeToFillImage<ViewController: UIViewController>(forVC vc: ViewController) -> Disposable
        where ViewController: KYCDocumentTypeAware & KYCPhotoPlaceholder
    {
        return subscribe(onNext: {[weak vc] kycModel in
            guard let vc = vc else { return }
            
            if let imageUrlStr = kycModel.imageUrl(for: vc.kYCDocumentType), let imageUrl = URL(string: imageUrlStr)  {
                vc.photoPlaceholder.photoImage.isHidden = false
                vc.photoPlaceholder.photoImage.af_setImage(withURL: imageUrl, useToken: true, showLoadingInContainer: vc.photoPlaceholder.view)
                return
            }
            
            if let image = kycModel.image(for: vc.kYCDocumentType) {
                vc.photoPlaceholder.photoImage.isHidden = false
                vc.photoPlaceholder.photoImage.image = image
                return
            }
        })
    }
    
    func subscribeToFillIcon(
        forType type: KYCDocumentType,
        inButtonBar buttonBar: ButtonBarView
    ) -> Disposable {
        return subscribe(onNext: {[weak buttonBar] documents in
            let status = documents.status(for: type)
            
            guard let cell = buttonBar?.cellForItem(at: IndexPath(row: type.index, section: 0)) as? KYCTabCollectionViewCell else {
                return
            }
            
            cell.image.image = status.image
            cell.image.isHidden = status.image == nil
        })
    }
}

fileprivate extension ObservableType where Self.E == KYCDocumentType? {
    func bindToDisable(button: UIBarButtonItem) -> Disposable {
        return filterNil()
            .map{documentType in documentType.next != nil}
            .bind(to: button.rx.isEnabled)
    }
}

fileprivate extension ObservableType where Self.E == (LWKYCDocumentsModel, KYCDocumentType) {
    
    func mapToStatus() -> Observable<KYCDocumentStatus> {
        return map{$0.0.status(for: $0.1)}
    }
}

fileprivate extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, Self.E == UIImage {
    func driveToReplacePlaceHolder(inVC vc: KYCTabStripViewController) -> Disposable {
        return drive(onNext: {[weak vc] image in
            guard let vc = vc, let photoHolder = vc.currentPhotoPlaceHolder else{return}
            photoHolder.photoPlaceholder.photoImage.isHidden = false
            photoHolder.photoPlaceholder.photoImage.image = image
        })
    }
}


//MARK: Factories
fileprivate extension KYCTabStripViewController {
    func factoryImagePickerController() -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        imagePicker.delegate = self
        
        return imagePicker
    }
}
