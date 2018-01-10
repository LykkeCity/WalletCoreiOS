platform :ios, '9.1'
inhibit_all_warnings!

target 'ModernMoney' do
use_frameworks!

pod 'Fabric', '~> 1.7.2'
pod 'Crashlytics', '~> 3.9.3'
pod 'MBProgressHUD'
pod 'Toast'
pod 'SWTableViewCell'
pod 'Firebase/Core'
pod 'Alamofire', '~> 4.4'
pod 'AlamofireImage', '~> 3.1'
pod 'Charts', '~> 3.0'
pod 'SideMenu'
pod 'SwiftReorder', '~> 2.0'
pod 'RxDataSources', '~> 1.0'
pod 'KYDrawerController'
pod 'TextFieldEffects', '~> 1.3'
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
