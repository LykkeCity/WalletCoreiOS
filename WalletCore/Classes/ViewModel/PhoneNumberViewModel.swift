//
//  PhoneNumberViewModel.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/25/17.
//
//

import Foundation
import RxSwift
import RxCocoa

open class PhoneNumberViewModel {
    
    public let fake = Variable<String>("")
    public let phonenumber = Variable<String>("")

    
    public let loading: Observable<Bool>
    public let loadingSaveChanges: Observable<Bool>
    public let countryCodesResult: Driver<ApiResult<LWPacketCountryCodes>>
    
    public let saveSettingsResult: Driver<ApiResult<LWPacketPhoneVerificationSet>>
    
    public init(saveSubmit: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        fake.value = "0"
        countryCodesResult = authManager.getHomeCountry.request().asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
    
        loading = self.countryCodesResult.asObservable().isLoading()
        // loading = result.asObservable().isLoading()
        
        saveSettingsResult = saveSubmit
            .throttle(1, scheduler: MainScheduler.instance)
            .mapPhoneNumber(phone: phonenumber, authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        loadingSaveChanges = saveSettingsResult.asObservable().isLoading()
        
    }
    
    public var isValid : Observable<Bool>{
        return Observable.combineLatest( self.fake.asObservable() , self.phonenumber.asObservable(), resultSelector:
            {(fake, phonenumber) -> Bool in
                return fake.characters.count > 0
                    && phonenumber.characters.count > 0
        })
    }
    
}

fileprivate extension ObservableType where Self.E == Void {

    
    func mapPhoneNumber(
        phone: Variable<String>,
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketPhoneVerificationSet>> {
        
        return flatMapLatest{authData in
            authManager.setPhoneNumber.request(withParams: phone.value)
            }
            .shareReplay(1)
    }
}
