platform :ios, '9.0'
inhibit_all_warnings!

target 'ModernWallet' do
use_frameworks!

pod 'Fabric'
pod 'Crashlytics'
pod 'MBProgressHUD'
pod 'Toast'
pod 'SWTableViewCell'
pod 'Google/Analytics'
pod 'Alamofire', '~> 4.4'
pod 'AlamofireImage', '~> 3.1'
pod 'Charts', '~> 3.0'
pod 'SideMenu'
pod 'SwiftReorder', '~> 2.0'
pod 'RxDataSources', '~> 1.0'
pod 'KYDrawerController'
pod 'TextFieldEffects', '~> 1.3'
pod 'RxKeyboard', '~> 0.6.2'
pod 'XLPagerTabStrip', '~> 7.0'
pod 'WalletCore', :path => '../WalletCoreiOS'
pod 'SwiftSpinner'
end

post_install do |installer_representation|
    installer_representation.pods_project.build_configurations.each do |config|
        if config.name == 'Release.Test' || config.name == 'Debug.Test'
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= []
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] |= ['$(inherited)', 'TEST=1']
        end
    end
end