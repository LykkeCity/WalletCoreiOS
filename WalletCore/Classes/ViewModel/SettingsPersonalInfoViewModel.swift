//
//  SettingsPersonalInfoViewModel.swift
//  Pods
//
//  Created by Nikola Bardarov on 8/24/17.
//
//

import Foundation
import RxSwift
import RxCocoa

open class SettingsPersonalInfoViewModel  {
    
    public let firstName = Variable<String>("")
    public let lastName = Variable<String>("")
    
    public let loading: Observable<Bool>
    public let loadingSaveChanges: Observable<Bool>
    public let result: Driver<ApiResult<LWPacketPersonalData>>
    public let countryCodesResult: Driver<ApiResultList<LWCountryModel>>
    
    public let saveSettingsResult: Driver<ApiResult<LWPacketClientFullNameSet>>
    
    public init(saveSubmit: Observable<Void>, authManager: LWRxAuthManager = LWRxAuthManager.instance)
    {
        result = authManager.settings.getPersonalData().asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))//countryCodes
        countryCodesResult = authManager.countryCodes.requestCountryCodes().asDriver(onErrorJustReturn: ApiResultList.error(withData: [:]))
        
        let m = Observable.merge([self.result.asObservable().isLoading(), self.countryCodesResult.asObservable().isLoading()])
        loading = m
       // loading = result.asObservable().isLoading()
        
        saveSettingsResult = saveSubmit
            .throttle(1, scheduler: MainScheduler.instance)
            .mapToFullName(firstName: firstName, lastName: lastName,authManager: authManager)
            .asDriver(onErrorJustReturn: ApiResult.error(withData: [:]))
        
        loadingSaveChanges = saveSettingsResult.asObservable().isLoading()
        
    }

    public var isValid : Observable<Bool>{
        return Observable.combineLatest( self.firstName.asObservable() , self.lastName.asObservable(), resultSelector:
            {(firstName, lastName) -> Bool in
                return firstName.characters.count > 0
                    && lastName.characters.count > 0
        })
    }
    
}

fileprivate extension ObservableType where Self.E == Void {
    func mapToFullName(
        firstName: Variable<String>,
        lastName: Variable<String>,
        authManager: LWRxAuthManager
        ) -> Observable<ApiResult<LWPacketClientFullNameSet>> {
        
        return flatMapLatest{authData in
                authManager.setFullName.setFullName(withName: firstName.value + " " + lastName.value)
            }
            .shareReplay(1)
    }
}

