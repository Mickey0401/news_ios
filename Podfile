# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'
inhibit_all_warnings!
target 'havr' do
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!
    
    # Pods for havr
    # Networking
    pod 'Alamofire'
    pod 'SwiftyJSON'
    
    # UI
    # AlertView
    pod 'SVWebViewController'
    pod 'SHGWebViewController', '~> 4.0.0'
    pod 'MBProgressHUD'
    pod 'TPKeyboardAvoiding'
    pod 'KDCircularProgress'
    #pod 'NVActivityIndicatorView'
    pod 'EZLoadingActivity'    
    #pod 'RAMReel' #real search at editProfile Interesnt
    pod 'FaceAware' # face recognition at ImageView
    pod 'Koloda', '~> 4.0' # Nearby Connection
    #pod 'SwiftForms' #Forms in textFields
    #pod 'BouncyLayout' # messages bounce
    #pod 'MMTabBarAnimation' # tabbar badge animation
    #pod 'SwiftPullToRefresh' # CAT PULL TO REFRESH
    #pod 'Newly' # NEW POST arrived to broadcast
    pod 'KanvasCameraSDK', :path => 'havr/Cocoapod/Universal'
    pod 'LTMorphingLabel', '0.5.3'
    #UI solutions
    pod 'SkeletonView'
    pod 'PhoneNumberKit', '~> 2.1'
    pod 'OnlyPictures'
    pod 'KILabel', '1.0.0'
    pod 'Whisper', '5.1.0'
    pod 'DZNEmptyDataSet'
    pod 'TOWebViewController'
    # DB
    pod 'RealmSwift'
    
    # Imaging
    pod 'Kingfisher', '~> 3'
    #  pod 'BSImagePicker'
    
    # Google Maps & Firebase
    pod 'GoogleMaps'
    pod 'GooglePlaces'
    pod 'GooglePlacePicker'
    pod 'Firebase/Core'
    pod 'Firebase/Messaging'
    pod 'Firebase/Analytics'

#    pod 'Google/Analytics'
#    pod 'Google-Maps-iOS-Utils'

    # Social
    pod 'TwitterKit'
    pod 'FacebookCore'
    pod 'FacebookLogin'
#    pod 'FacebookShare'

    # Security
    pod 'SwiftKeychainWrapper'
    
    pod 'SwiftyTimer'
    pod 'UIScrollView-InfiniteScroll'

    pod 'AWSS3', '~> 2.5'
    
    pod 'Starscream'
    
    pod 'ReachabilitySwift', '~> 3'
    
    pod 'Fabric'
    pod 'Crashlytics'
    # Photo Filter
    pod 'Vivid'
    pod 'YUCIHighPassSkinSmoothing'
    pod 'PRTween', '~> 0.0.1'
    pod 'ExpandableLabel'
end

pre_install do |installer|
    def installer.verify_no_static_framework_transitive_dependencies; end
end
