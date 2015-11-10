platform :ios, '7.0'

pod 'Mapbox-iOS-SDK'
pod 'InnerBand'
pod 'AFNetworking'
pod 'MBProgressHUD'
pod 'gtm-oauth'
pod 'MWPhotoBrowser'

use_frameworks!

# disable bitcode in every sub-target
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end