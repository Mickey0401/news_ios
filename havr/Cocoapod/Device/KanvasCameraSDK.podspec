Pod::Spec.new do |s|
    s.name              = 'KanvasCameraSDK'
    s.version           = '1.0.0'
    s.summary           = 'Camera and Editing Tools SDK'
    s.homepage          = 'http://getkanvas.com/'

    s.author            = { 'Name' => 'tony@getkanvas.com' }
    s.license           = { :type => 'proprietary', :file => 'LICENSE' }

    s.platform          = :ios
    s.source            = { :http => 'http://getkanvas.com' }

    s.ios.deployment_target = '8.0'

    s.frameworks = 'UIKit', 'SystemConfiguration', 'Security'
    s.dependency 'AFNetworking', '3.1.0'
    s.dependency 'SDWebImage', '4.0.0'
    s.dependency 'GPUImage', '0.1.7'
    s.dependency 'FLAnimatedImage', '1.0.12'

    s.vendored_frameworks = 'KanvasCameraSDK.framework'
end
