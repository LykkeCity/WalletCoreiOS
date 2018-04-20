//
//  CreditCardBaseInfoViewModel.swift
//  Pods
//
//  Created by Georgi Stanev on 8/19/17.
//
//
import Foundation
import RxSwift
import RxCocoa

open class CreditCardBaseInfoViewModel {
    fileprivate typealias Input = (
        amount: Variable<String>,
        firstName: Variable<String>, lastName: Variable<String>,
        city: Variable<String>, zip: Variable<String>, address:Variable<String>, country: Variable<String>,
        email: Variable<String>, phone: Variable<String>, phoneCode: Variable<String>,
        asset: Variable<LWAssetModel?>
    )
    
    /// <#Description#>
    public let input = Input(
        amount: Variable(""),
        firstName: Variable(""), lastName: Variable(""),
        city: Variable(""), zip: Variable(""), address:Variable(""), country: Variable(""),
        email: Variable(""), phone: Variable(""), phoneCode: Variable(""),
        asset: Variable<LWAssetModel?>(nil)
    )
    
    public let errors: Errors
    
    public let loadingViewModel: LoadingViewModel
    
    /// <#Description#>
    public let paymentUrlResult: Observable<ApiResult<LWPacketGetPaymentUrl>>
    public let assetSymbol: Driver<String>
    public let assetCode: Driver<String>
    
    private let disposeBag = DisposeBag()
    private let countryCodes = Variable<[LWCountryModel]>([])
    
    public init(submit: Observable<Void>,
                assetToAdd: Observable<LWAssetModel>,
                authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        let personalData =  authManager.prevCardPayment.request()
        let countryCodes =  authManager.countryCodes.request()
        
        paymentUrlResult = submit
            .throttle(1, scheduler: MainScheduler.instance)
            .mapToPaymentUrl(input: input, countries: self.countryCodes, authManager: authManager)
        
        loadingViewModel = LoadingViewModel([
            paymentUrlResult.isLoading(),
            personalData.isLoading()
        ])
        
        assetSymbol = input.asset.asObservable()
            .filterNil()
            .mapToSymbol()
            .asDriver(onErrorJustReturn: "")
        
        assetCode = input.asset.asObservable()
            .filterNil()
            .mapToDisplayId()
            .asDriver(onErrorJustReturn: "")
     
        assetToAdd.bind(to: input.asset)
            .disposed(by: disposeBag)
        
        personalData.filterSuccess()
            .bind(toInput: input, withCountries: countryCodes.filterSuccess(), disposedBy: disposeBag)
        
        countryCodes
            .filterSuccess()
            .bind(to: self.countryCodes)
            .disposed(by: disposeBag)
        
        errors = Errors(withPacket: paymentUrlResult, input: input)
    }
    
    public class Errors {
        public let amount: Driver<String?>
        public let firstName: Driver<String?>
        public let lastName: Driver<String?>
        public let city: Driver<String?>
        public let zip: Driver<String?>
        public let address: Driver<String?>
        public let country: Driver<String?>
        public let email: Driver<String?>
        public let phone: Driver<String?>
        public let phoneCode: Driver<String?>
        
        public let errorMessage: Driver<String>
        
        fileprivate init(withPacket packet: Observable<ApiResult<LWPacketGetPaymentUrl>>, input: Input) {
            let error = Observable.merge(
                packet.filterError(),
                packet.filterSuccess().map{_ -> [AnyHashable: Any] in [:]}
            )
            
            amount = error.asDriver(byFieldName: "Amount")
            firstName = error.asDriver(byFieldName: "FirstName")
            lastName = error.asDriver(byFieldName: "LastName")
            city = error.asDriver(byFieldName: "City")
            zip = error.asDriver(byFieldName: "Zip")
            address = error.asDriver(byFieldName: "Address")
            country = error.countryAsDriver(country: input.country)
            email = error.asDriver(byFieldName: "Email")
            phone = error.asDriver(byFieldName: "Phone")
            phoneCode = error.asDriver(byFieldName: "Phone")
            
            errorMessage = error.mapToMessage().asDriver(onErrorJustReturn: "")
        }
    }
}

fileprivate extension ObservableType where Self.E == LWPersonalDataModel {
    func bind(
        toInput input: CreditCardBaseInfoViewModel.Input,
        withCountries countries: Observable<[LWCountryModel]>,
        disposedBy disposeBag: DisposeBag
    ) {
        let combinedObservable = Observable.combineLatest(self, countries){(personal: $0, countries: $1)}
        
        map{$0.firstName}
            .bind(to: input.firstName)
            .disposed(by: disposeBag)
        
        map{$0.lastName}
            .bind(to: input.lastName)
            .disposed(by: disposeBag)
        
        map{$0.address}
            .bind(to: input.address)
            .disposed(by: disposeBag)
        
        map{$0.city}
            .bind(to: input.city)
            .disposed(by: disposeBag)
        
        combinedObservable
            .bind(toCountry: input.country)
            .disposed(by: disposeBag)
        
        map{$0.zip}
            .bind(to: input.zip)
            .disposed(by: disposeBag)
        
        map{$0.email}
            .bind(to: input.email)
            .disposed(by: disposeBag)
        
        combinedObservable
            .bind(toPhoneCode: input.phoneCode)
            .disposed(by: disposeBag)
        
        combinedObservable
            .bind(toPhone: input.phone)
            .disposed(by: disposeBag)
    }
}

fileprivate extension ObservableType where Self.E == (personal: LWPersonalDataModel, countries: [LWCountryModel]) {
    func bind(toCountry country: Variable<String>) -> Disposable {
        return
            map{data in
                data.countries
                    .first{country in country.iso2 == data.personal.country}
                    .map{$0.name}
            }
            .filterNil()
            .bind(to: country)
    }
    
    func bind(toPhoneCode phoneCode: Variable<String>) -> Disposable {
        return
            map{data in
                data.countries
                    .first{country in data.personal.phone.contains(country.prefix)}
            }
            .filterNil()
            .map{$0.prefix}.filterNil()
            .bind(to: phoneCode)
    }
    
    func bind(toPhone phone: Variable<String>) -> Disposable {
        return
            map{data in
                let matchedCountry = data.countries
                        .first{country in data.personal.phone.contains(country.prefix)}
                
                return data.personal.phone
                    .replacingOccurrences(of: matchedCountry?.prefix ?? "", with: "")
            }
            .bind(to: phone)
    }
}

extension ObservableType where Self.E == LWAssetModel {
    func mapToSymbol() -> Observable<String> {
        return map{$0.symbol}
            .replaceNilWith("")
            .startWith("")
    }
    
    func mapToIdentity() -> Observable<String> {
        return map{$0.identity}
            .replaceNilWith("")
            .startWith("")
    }
    
    func mapToDisplayId() -> Observable<String> {
        return map { $0.displayId }
            .replaceNilWith("")
            .startWith("")
    }
}

fileprivate extension ObservableType where Self.E == Void {
    
    func mapToPaymentUrl(input: CreditCardBaseInfoViewModel.Input, countries: Variable<[LWCountryModel]>, authManager: LWRxAuthManager)
        -> Observable<ApiResult<LWPacketGetPaymentUrl>> {
        return map{
                let country = countries.value.first{country in country.name == input.country.value}
            
                return LWPacketGetPaymentUrlParams(
                    amount: input.amount.value,
                    firstName: input.firstName.value,
                    lastName: input.lastName.value,
                    city: input.city.value,
                    zip: input.zip.value,
                    address: input.address.value,
                    country: country?.iso2 ?? "",
                    email: input.email.value,
                    phone: "\(input.phoneCode.value)\(input.phone.value)",
                    assetId: input.asset.value?.identity ?? ""
                )
            }
            .flatMapLatest{params in
                authManager.paymentUrl.request(withParams: params)
            }
            .shareReplay(1)
            
    }
}

fileprivate extension ObservableType where Self.E == [AnyHashable: Any] {
    func mapToMessage() -> Observable<String> {
        return map{$0["Message"] as? String}.filterNil()
    }
    
    func filter(byField field: String) -> Observable<[AnyHashable: Any]> {
        return filter{
            guard let fieldName = $0["Field"] as? String, fieldName == field else {return false}
            return true
        }
    }
    
    func mapToMessage(byFieldName field: String) -> Observable<String?> {
        return map{
            guard let fieldName = $0["Field"] as? String, fieldName == field else {return nil}
            return $0["Message"] as? String
        }
    }
    
    func asDriver(byFieldName fieldName: String) -> Driver<String?> {
        return mapToMessage(byFieldName: fieldName)
            .asDriver(onErrorJustReturn: "")
    }
    
    func countryAsDriver(country: Variable<String>) -> Driver<String?> {
        return map{
            guard let fieldName = $0["Field"] as? String, fieldName == "Country" else {return nil}
            if country.value.isNotEmpty {return Localize("Country field is invalid.")}
            return $0["Message"] as? String
        }
        .asDriver(onErrorJustReturn: "")
    }
}
