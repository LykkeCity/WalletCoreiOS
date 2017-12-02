//
//  PledgeService.swift
//  WalletCore
//
//  Created by Georgi Stanev on 29.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public class PledgeService {
    
    private let treeToKGEmission = 25
    
    
    /// Calculates remaining pledge in kilos
    ///
    /// - Parameters:
    ///   - pledge: PledgeModel
    ///   - trees: TREEs count
    /// - Returns: Kilos amount
    public func calculateRemainingKilos(forPledge pledge: PledgeModel, withTrees trees: Int) -> Int {
        return Int.abs(calculateGoal(forPledge: pledge) - calculateEmission(forTreeCount: trees))
    }
    
    /// Calculates remaining pledge in TREEs
    ///
    /// - Parameters:
    ///   - pledge: PledgeModel
    ///   - trees: TREEs count
    /// - Returns: TREEs amount
    public func calculateRemainingTrees(forPledge pledge: PledgeModel, withTrees trees: Int) -> Int {
        return Int.abs(calculateRemainingKilos(forPledge: pledge, withTrees: trees) / treeToKGEmission)
    }
    
    /// Calculates percent of pledge completed
    ///
    /// - Parameters:
    ///   - pledge: PledgeModel
    ///   - trees: TREEs count
    /// - Returns: Percent amount
    public func calculatePecent(forPledge pledge: PledgeModel, withTrees trees: Int) -> Double {
        return Double(calculateEmission(forTreeCount: trees)) / Double(calculateGoal(forPledge: pledge)) * 100.0
    }
    
    /// Calculate goal in Kg
    ///
    /// - Parameter pledge: Pledge model
    /// - Returns: Goal in Kg
    public func calculateGoal(forPledge pledge: PledgeModel) -> Int {
        return pledge.footprint * pledge.netPositiveValue
    }
    
    /// Calculates emission in Kilos
    ///
    /// - Parameter TREEs count
    /// - Returns: Emission kilos
    public func calculateEmission(forTreeCount treeCount: Int) -> Int {
        return treeCount * treeToKGEmission
    }
}
