//
//  PledgeService.swift
//  WalletCore
//
//  Created by Georgi Stanev on 29.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public class PledgeService {
    
    private let treeToKGEmision = 25
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - pledge: <#pledge description#>
    ///   - trees: <#trees description#>
    /// - Returns: <#return value description#>
    public func calculateRemainingTones(forPledge pledge: PledgeModel, withTrees trees: Int) -> Int {
        return Int.abs(calculateGoal(forPledge: pledge) - calculateEmission(forTreeCount: trees))
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - pledge: <#pledge description#>
    ///   - trees: <#trees description#>
    /// - Returns: <#return value description#>
    public func calculateRemainingTrees(forPledge pledge: PledgeModel, withTrees trees: Int) -> Int {
        return Int.abs(calculateRemainingTones(forPledge: pledge, withTrees: trees) / treeToKGEmision)
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - pledge: <#pledge description#>
    ///   - trees: <#trees description#>
    /// - Returns: <#return value description#>
    public func calculatePecent(forPledge pledge: PledgeModel, withTrees trees: Int) -> Int {
        return calculateEmission(forTreeCount: trees) / calculateGoal(forPledge: pledge)
    }
    
    /// Calculate goal in Kg
    ///
    /// - Parameter pledge: Pledge model
    /// - Returns: Goal in Kg
    public func calculateGoal(forPledge pledge: PledgeModel) -> Int {
        return pledge.footprint * pledge.netPositiveValue
    }
    
    /// <#Description#>
    ///
    /// - Parameter treeCount: <#treeCount description#>
    /// - Returns: <#return value description#>
    public func calculateEmission(forTreeCount treeCount: Int) -> Int {
        return treeCount * treeToKGEmision
    }
}
