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
    
    /// Example: 0.75
    public let percentFraction: Driver<Double>
    
    /// 600t CO2/year
    public let positiveTonsPerYear: Driver<String>
    
    public let pledgeTaken: Driver<Bool>
    
    public let loadingViewModel: LoadingViewModel
    
    public init(
        blueManager: LWRxBlueAuthManager = LWRxBlueAuthManager.instance,
        authManager: LWRxAuthManager = LWRxAuthManager.instance,
        pledgeService: PledgeService = PledgeService()
    ) {
        let pledge = blueManager.pledgeGet.request()
        let wallets = authManager.lykkeWallets.request(byAssetName: blueManager.treeAssetName)
        
        let pledgeAndTrees = Observable.zip(pledge.filterSuccess(), wallets.mapToTrees()){((pledge: $0, trees: $1))}
        
        footprintTons = pledge
            .mapToFootPrint()
            .asDriver(onErrorJustReturn: "")
        
        goalMultiplier = pledge
            .mapToGoal()
            .asDriver(onErrorJustReturn: "")
        
        goalTons = pledge
            .mapToGoalTons(withService: pledgeService)
            .asDriver(onErrorJustReturn: "")
        
        pledgeTaken = pledge
            .map{ return $0.getSuccess() != nil }
            .asDriver(onErrorJustReturn: false)
        
        remainingTons = pledgeAndTrees
            .mapToRemainingTons(withService: pledgeService)
            .asDriver(onErrorJustReturn: "")
        
        remainingTrees = pledgeAndTrees
            .mapToRemainingTrees(withService: pledgeService)
            .asDriver(onErrorJustReturn: "")
        
        percentComplete = pledgeAndTrees
            .mapToPercent(withService: pledgeService)
            .asDriver(onErrorJustReturn: "")
        
        percentFraction = pledgeAndTrees
            .mapPercentToFraction(withService: pledgeService)
            .asDriver(onErrorJustReturn: 0.0)
        
        positiveTonsPerYear = wallets
            .mapToPositivePerYear(withService: pledgeService)
            .asDriver(onErrorJustReturn: "")
        
        loadingViewModel = LoadingViewModel([
            pledge.isLoading(),
            wallets.isLoading()
        ])
    }
}

fileprivate extension ObservableType where Self.E == ApiResult<LWSpotWallet?> {
    func mapToTrees() -> Observable<Int> {
        return filterSuccess()
            .map{ $0?.balance.intValue }
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
            .map{ $0.footprint }
            .mapToTons()
            .map { "\($0)t" }
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
            .map{ "\($0) TREE" }
            
    }
    
    func mapToRemainingTons(withService service: PledgeService) -> Observable<String> {
        return
            map{ service.calculateRemainingKilos(forPledge: $0.pledge, withTrees: $0.trees) }
            .mapToTons()
            .map{ "\($0)t" }
    }
    
    func mapToPercent(withService service: PledgeService) -> Observable<String> {
        return
            map{ service.calculatePecent(forPledge: $0.pledge, withTrees: $0.trees) }
            .map{ NumberFormatter.percentInstance.string(for: $0) }
            .replaceNilWith("")
    }
    
    func mapPercentToFraction(withService service: PledgeService) -> Observable<Double> {
        return map{ service.calculatePecent(forPledge: $0.pledge, withTrees: $0.trees) / 100.0 }
    }
}
