//
//  ProfilePledgeViewModel.swift
//  WalletCore
//
//  Created by Georgi Stanev on 29.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public class ProfilePledgeViewModel {
    
    /// Example: 80t
    public let footprintTons: Driver<String>
    
    /// Example: 10x
    public let goalMultiplier: Driver<String>
    
    /// Example: 800t CO2
    public let goalTons: Driver<String>
    
    /// Example: 200t
    public let remainingTons: Driver<String>
    
    /// Example 8,000 TREE
    public let remainingTrees: Driver<String>
    
    /// Example: 75%
    public let percentComplete: Driver<String>
    
    /// 600t CO2/year
    public let positiveTonsPerYear: Driver<String>
    
    public let loadingViewModel: LoadingViewModel
    
    public init(
        blueManager: LWRxBlueAuthManager = LWRxBlueAuthManager.instance,
        authManager: LWRxAuthManager = LWRxAuthManager.instance,
        pledgeService: PledgeService = PledgeService()
    ) {
        let pledge = blueManager.pledgeGet.request()
        let wallets = authManager.lykkeWallets.requestNonEmptyWallets()
        
        let pledgeAndTrees = Observable.zip(pledge.filterSuccess(), wallets.mapToTrees()){((pledge: $0, trees: $1))}
        
        footprintTons = pledge
            .mapToFootPrint()
            .asDriver(onErrorJustReturn: "")
        
        goalMultiplier = pledge
            .mapToFootPrint()
            .asDriver(onErrorJustReturn: "")
        
        goalTons = pledge
            .mapToGoalTons(withService: pledgeService)
            .asDriver(onErrorJustReturn: "")
        
        remainingTons = pledgeAndTrees
            .mapToRemainingTons(withService: pledgeService)
            .asDriver(onErrorJustReturn: "")
        
        remainingTrees = pledgeAndTrees
            .mapToRemainingTrees(withService: pledgeService)
            .asDriver(onErrorJustReturn: "")
        
        percentComplete = pledgeAndTrees
            .mapToPercent(withService: pledgeService)
            .asDriver(onErrorJustReturn: "")
        
        positiveTonsPerYear = wallets
            .mapToPositivePerYear(withService: pledgeService)
            .asDriver(onErrorJustReturn: "")
        
        loadingViewModel = LoadingViewModel([
            pledge.isLoading(),
            wallets.isLoading()
        ])
    }
}

fileprivate extension ObservableType where Self.E == ApiResultList<LWSpotWallet> {
    func mapToTrees() -> Observable<Int> {
        return
            filterSuccess()
            .map{
                $0.reduce(0.0){acumulator, wallet -> Decimal in
                    return acumulator + wallet.balance.decimalValue
                }
            }
            .map{ Int(exactly: $0.doubleValue) }
            .replaceNilWith(0)
    }
    
    func mapToPositivePerYear(withService service: PledgeService) -> Observable<String> {
        return mapToTrees()
            .map{ service.calculateEmission(forTreeCount: $0) }
            .mapToTons()
            .map{ "\($0)t CO2/year" }
    }
}

fileprivate extension ObservableType where Self.E == ApiResult<PledgeModel> {
    func mapToFootPrint() -> Observable<String> {
        return filterSuccess()
            .map{ "\($0.footprint)t" }
            .startWith("")
    }
    
    func mapToGoal() -> Observable<String> {
        return filterSuccess()
            .map{ "\($0.netPositiveValue)x" }
            .startWith("")
    }
    
    func mapToGoalTons(withService service: PledgeService) -> Observable<String> {
        return filterSuccess()
            .map{ service.calculateGoal(forPledge: $0) }
            .mapToTons()
            .map{ "\($0)t CO2" }
    }
}

fileprivate extension ObservableType where Self.E == Int {
    func mapToTons() -> Observable<Int> {
        return map{ $0 / 1000 }
    }
}

fileprivate extension ObservableType where Self.E == (pledge: PledgeModel, trees: Int) {
    func mapToRemainingTrees(withService service: PledgeService) -> Observable<String> {
        return
            map{ service.calculateRemainingTrees(forPledge: $0.pledge, withTrees: $0.trees) }
            .map{ NumberFormatter.currencyInstance(accuracy: 0).string(from: NSNumber(value: $0)) }
            .replaceNilWith("")
    }
    
    func mapToRemainingTons(withService service: PledgeService) -> Observable<String> {
        return
            map{ service.calculateRemainingTones(forPledge: $0.pledge, withTrees: $0.trees) }
            .mapToTons()
            .map{ "\($0)t" }
    }
    
    func mapToPercent(withService service: PledgeService) -> Observable<String> {
        return
            map{ service.calculatePecent(forPledge: $0.pledge, withTrees: $0.trees) }
            .map{ NumberFormatter.percentInstance.string(from: NSNumber(value: $0)) }
            .replaceNilWith("")
    }
}
