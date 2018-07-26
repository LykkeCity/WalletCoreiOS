//
//  SelectCountryViewModel.swift
//  WalletCore
//
//  Created by Nacho Nachev  on 11.01.18.
//  Copyright © 2018 Lykke. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class SelectCountryViewModel {

    public struct CountrySection {
        public let sectionName: String
        public let countries: [LWCountryModel]
    }

    public let sections = Variable<[CountrySection]>([])

    public let searchText = Variable("")

    public let searchResult = Variable<[LWCountryModel]>([])

    private let countries = Variable<[LWCountryModel]>([])

    private let disposeBag = DisposeBag()

    public init(authManager: LWRxAuthManager = LWRxAuthManager.instance) {
        authManager.countryCodes.request()
            .filterSuccess()
            .bind(to: countries)
            .disposed(by: disposeBag)

        countries.asObservable()
            .map { allCountries in
                var sections = [CountrySection]()
                for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
                    let sectionName = "\(char)"
                    let countries = allCountries.filter { $0.name.hasPrefix(sectionName) }.sorted { $0.0.name < $0.1.name }
                    if countries.count == 0 {
                        continue
                    }
                    sections.append(CountrySection(sectionName: sectionName, countries: countries))
                }
                return sections
            }
            .bind(to: sections)
            .disposed(by: disposeBag)

        Observable.combineLatest(countries.asObservable(), searchText.asObservable())
            .map { data -> [LWCountryModel] in
                let (countries, searchText) = data
                guard searchText.count > 0 else { return [] }
                return countries.filter { $0.name.lowercased().hasPrefix(searchText.lowercased())}
            }
            .bind(to: searchResult)
            .disposed(by: disposeBag)
    }

    public func countryBy(name: String?) -> LWCountryModel? {
        guard let name = name else {
            return nil
        }
        return countries.value.filter { $0.name == name }.first
    }

}
