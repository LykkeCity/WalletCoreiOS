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
    
    let treeCoinIdentifier = "c33f03ea-bacd-4d26-a676-539ef5e8ec74"
    
    public lazy var twitterJson = { LWRxAuthManagerTwitterTimeLineJson() }()
    public lazy var pledgePost = { LWRxBlueAuthManagerPledgePost() }()
    public lazy var pledgeGet = { LWRxBlueAuthManagerPledgeGet() }()
    public lazy var getCommunityUsersCount = { LWRxBlueAuthManagerCommunityUsersCount() }()
    public lazy var referralLink = { LWRxBlueAuthManagerReferralLink() }()
    public lazy var referralLinkInfo = { LWRxBlueAuthManagerReferralLinkInfo() }()
    public lazy var claimReferralLink = { LWRxBlueAuthManagerClaimReferralLink() }()
}
