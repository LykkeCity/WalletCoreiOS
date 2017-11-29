//
//  LWRxBlueAuthManager.swift
//  WalletCore
//
//  Created by Georgi Stanev on 28.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation

public class LWRxBlueAuthManager {
    public static let instance = LWRxBlueAuthManager()
    private init() {}
    
    public lazy var twitterJson = { LWRxAuthManagerTwitterTimeLineJson() }()
    public lazy var pledgePost = { LWRxBlueAuthManagerPledge() }()
}
