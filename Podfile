platform :ios, '9.1'
inhibit_all_warnings!

target 'ModernMoney' do
use_frameworks!

pod 'Fabric'
pod 'Crashlytics'
pod 'MBProgressHUD'
pod 'Toast'
pod 'SWTableViewCell'
pod 'Firebase/Core'
pod 'Alamofire', '~> 4.4'
pod 'AlamofireImage', '~> 3.1'
pod 'Charts', '3.0.2'
pod 'SideMenu'
pod 'SwiftReorder', '~> 2.0'
pod 'RxDataSources', '~> 1.0'
pod 'KYDrawerController'
pod 'TextFieldEffects', '~> 1.3'
pod 'XLPagerTabStrip', '~> 7.0'
pod 'WalletCore', :path => '../WalletCoreiOS'
pod 'SwiftSpinner', :git => 'https://github.com/StoykovPrime/SwiftSpinner', :branch => 'endless-loading-during-hide-transition'
pod 'QRCodeReader.swift', '~> 7.5.0'
pod 'Koyomi', :git => 'https://github.com/whoislyuboanyway/Koyomi', :branch => 'show-border-instead-of-filled-background'
pod 'Siren', :git => 'https://github.com/ArtSabintsev/Siren.git', :branch => 'swift3.2'
pod 'UIScrollView-InfiniteScroll', '~> 1.0.0'
end

post_install do |installer_representation|
    installer_representation.pods_project.build_configurations.each do |config|
        if config.name == 'Release.Test' || config.name == 'Debug.Test'
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= []
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] |= ['$(inherited)', 'TEST=1']
        end
    end
end
